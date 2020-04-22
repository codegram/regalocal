defmodule Regalocal.Admin.Coupon do
  use Ecto.Schema
  import Ecto.Changeset

  schema "coupons" do
    field :amount, :decimal
    field :discount, :integer
    field :status, CouponStatusEnum
    field :terms, :string
    field :title, :string
    field :value, :integer
    field :business_id, :id
    field :description, :string
    field :archived, :boolean, default: false

    timestamps()
  end

  @doc false
  def changeset(coupon, attrs) do
    coupon
    |> cast(attrs, [
      :title,
      :amount,
      :value,
      :discount,
      :status,
      :terms,
      :business_id,
      :description,
      :archived
    ])
    |> validate_required([:title, :value, :discount, :status, :description, :business_id])
    |> validate_inclusion(:status, CouponStatusEnum.__valid_values__())
    |> validate_number(:value, greater_than_or_equal_to: 5)
    |> validate_number(:discount, greater_than_or_equal_to: 5, less_than_or_equal_to: 25)
    |> calculate_amount(coupon)
  end

  defp calculate_amount(changeset, coupon) do
    case changeset do
      %Ecto.Changeset{valid?: true} ->
        value = get_change(changeset, :value, coupon.value)
        discount = get_change(changeset, :discount, coupon.discount)

        amount = Float.round(value * (100 - discount) / 100, 2)

        changeset
        |> put_change(:amount, amount)

      _ ->
        changeset
    end
  end
end
