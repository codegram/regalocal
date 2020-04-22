defmodule RegalocalWeb.Orders.OrderRedeemedEmail do
  use Phoenix.Swoosh,
    view: RegalocalWeb.Orders.EmailView,
    layout: {RegalocalWeb.LayoutView, :email}

  import RegalocalWeb.PremailHelper
  import RegalocalWeb.Gettext

  def generate(gift, business) do
    new()
    |> to({gift.buyer_name, gift.buyer_email})
    |> reply_to({business.owner_name, business.email})
    |> from(from_email())
    |> subject(
      gettext("👍 El cupó que vas regalar s'ha utilitzat: \"%{reference}\"",
        reference: gift.reference
      )
    )
    |> render_body("order_redeemed.html", %{gift: gift, business: business})
    |> premail
  end

  defp from_email do
    {Application.get_env(:veil, :email_from_name),
     Application.get_env(:veil, :email_from_address)}
  end
end
