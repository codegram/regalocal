defmodule RegalocalWeb.Orders.GiftEmail do
  use Phoenix.Swoosh,
    view: RegalocalWeb.Orders.EmailView,
    layout: {RegalocalWeb.LayoutView, :email}

  import RegalocalWeb.PremailHelper
  import RegalocalWeb.Gettext

  def generate(gift, business) do
    gift = gift |> Regalocal.Repo.preload(:coupon)

    new()
    |> to({gift.recipient_name, gift.recipient_email})
    |> reply_to({gift.buyer_name, gift.buyer_email})
    |> from(from_email())
    |> subject(
      gettext("🎁 Has rebut un regal de part de %{buyer_name}!", buyer_name: gift.buyer_name)
    )
    |> render_body("gift_email.html", %{gift: gift, business: business})
    |> premail
  end

  defp from_email do
    {Application.get_env(:veil, :email_from_name),
     Application.get_env(:veil, :email_from_address)}
  end
end
