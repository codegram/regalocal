defmodule Regalocal.Profiles.Business do
  use Ecto.Schema
  import Ecto.Changeset
  import Logger
  alias Regalocal.Geolocation

  schema "businesses" do
    field(:address, :string)
    field(:billing_address, :string)
    field(:bizum_number, :string)
    field(:email, :string)
    field(:facebook, :string)
    field(:google_maps_url, :string)
    field(:iban, :string)
    field(:instagram, :string)
    field(:legal_name, :string)
    field(:name, :string)
    field(:owner_name, :string)
    field(:phone, :string)
    field(:story, :string)
    field(:tripadvisor_url, :string)
    field(:vat_number, :string)
    field(:website, :string)
    field(:whatsapp, :string)
    field :coordinates, Geo.PostGIS.Geometry
    field :distance_meters, :integer, virtual: true
    field :photo, :any, virtual: true
    field :photo_id, :string
    timestamps()
  end

  @doc false
  def changeset(business, attrs) do
    business
    |> cast(attrs, [
      :name,
      :owner_name,
      :story,
      :address,
      :phone,
      :website,
      :whatsapp,
      :google_maps_url,
      :tripadvisor_url,
      :instagram,
      :facebook,
      :iban,
      :legal_name,
      :vat_number,
      :billing_address,
      :bizum_number,
      :coordinates,
      :photo_id
    ])
    |> validate_required([
      :name,
      :owner_name,
      :story,
      :address,
      :phone,
      :iban,
      :legal_name,
      :vat_number,
      :billing_address
    ])
    |> format_iban
    |> format_vat
    |> validate_address
    |> format_phone(:phone)
    |> format_phone(:whatsapp)
    |> format_phone(:bizum_number)
    |> unique_constraint(:vat_number)
    |> unique_constraint(:iban)
  end

  def validate_address(changeset) do
    case changeset do
      %Ecto.Changeset{changes: %{address: raw_address}} ->
        case Geolocation.locate(raw_address) do
          {:ok, %Geolocation{address: address} = geo} ->
            changeset
            |> put_change(:address, address)
            |> put_change(:coordinates, Geolocation.to_geopoint(geo))

          {:error, error} ->
            Logger.error(error)
            changeset |> put_change(:coordinates, nil) |> add_error(:address, error)
        end

      _ ->
        changeset
    end
  end

  defp format_iban(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{iban: iban}} ->
        put_change(
          changeset,
          :iban,
          iban |> alphanumeric_upcase
        )

      _ ->
        changeset
    end
  end

  defp format_vat(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{vat_number: vat_number}} ->
        put_change(
          changeset,
          :vat_number,
          vat_number |> alphanumeric_upcase
        )

      _ ->
        changeset
    end
  end

  defp format_phone(changeset, field) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: changes} ->
        if value = Map.get(changes, field) do
          put_change(
            changeset,
            field,
            value |> alphanumeric_upcase
          )
        else
          changeset
        end

      _ ->
        changeset
    end
  end

  defp alphanumeric_upcase(str) do
    str |> String.upcase() |> String.replace(~r/[^A-Z0-9]+/, "")
  end
end
