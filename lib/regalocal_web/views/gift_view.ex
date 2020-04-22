defmodule RegalocalWeb.GiftView do
  use RegalocalWeb, :view
  import RegalocalWeb.PublicLayoutHelpers

  def title(:new, %{coupon: %{title: coupon_title}, business: %{name: business_name}}) do
    gettext("%{coupon_title} a %{business_name}",
      coupon_title: coupon_title,
      business_name: business_name
    )
  end
end
