defmodule RegalocalWeb.Orders.GiftIsReadyEmail do
  use Phoenix.Swoosh,
    view: RegalocalWeb.Orders.EmailView,
    layout: {RegalocalWeb.LayoutView, :email}

  import RegalocalWeb.PremailHelper
  import RegalocalWeb.Gettext

  def generate(gift, business) do
    new()
    |> to({gift.recipient_name, gift.recipient_email})
    |> cc({gift.buyer_name, gift.buyer_email})
    |> reply_to({gift.buyer_name, gift.buyer_email})
    |> from(from_email())
    |> subject(
      gettext("🎉 Ja pots gaudir del regal que et va fer %{buyer_name}!",
        buyer_name: gift.buyer_name
      )
    )
    |> render_body("gift_is_ready.html", %{gift: gift, business: business})
    |> premail
  end

  defp from_email do
    {Application.get_env(:veil, :email_from_name),
     Application.get_env(:veil, :email_from_address)}
  end
end
