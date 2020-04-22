defmodule Regalocal.Search do
  import Ecto.Query, warn: false
  import Geo.PostGIS

  alias Regalocal.Repo
  alias Regalocal.Admin.Business
  alias Regalocal.Admin.Coupon

  def find_businesses_near!(%Geo.Point{} = geom, limit_km) do
    bids = business_ids_with_coupons()

    Business
    |> select([b], %{b | distance_meters: st_distance_in_meters(b.coordinates, ^geom)})
    |> where([b], b.id in ^bids)
    |> where(accepted_terms: true)
    |> where([b], st_distance_in_meters(b.coordinates, ^geom) <= ^limit_km * 1000)
    |> order_by([b], st_distance_in_meters(b.coordinates, ^geom))
    |> Repo.all()
  end

  defp business_ids_with_coupons() do
    Coupon
    |> select([:business_id])
    |> where(
      [c],
      c.status in ["published", "redeemable"] and c.archived == false and
        not is_nil(c.business_id)
    )
    |> Repo.all()
    |> Enum.map(fn c -> c.business_id end)
    |> Enum.uniq()
  end

  def get_business!(id), do: Business |> where(id: ^id, accepted_terms: true) |> Repo.one!()

  def active_coupons_for(%Business{id: business_id}) do
    Coupon
    |> where(business_id: ^business_id)
    |> where([c], c.status in ["published", "redeemable"] and c.archived == false)
    |> Repo.all()
  end
end
