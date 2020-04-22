defmodule RegalocalWeb.Admin.CouponView do
  use RegalocalWeb, :view
  alias RegalocalWeb.FormHelpers, as: Form
  alias Regalocal.Admin
  alias Regalocal.Admin.Coupon

  alias RegalocalWeb.Admin.OrderView, as: Order

  alias RegalocalWeb.AdminLayoutHelpers, as: AdminHelpers

  def title(%Coupon{title: nil, value: value}), do: gettext("Cupó de %{value} EUR", value: value)
  def title(%Coupon{title: title}), do: title

  def status(%Coupon{status: :draft}), do: gettext("Esborrany")
  def status(%Coupon{status: :published}), do: gettext("Publicat")
  def status(%Coupon{status: :redeemable}), do: gettext("Bescanviable")

  def status_pill(%Coupon{} = coupon) do
    render("status.html", %{coupon: coupon, formatted_status: status(coupon)})
  end
end
