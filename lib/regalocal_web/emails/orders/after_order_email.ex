defmodule RegalocalWeb.Orders.AfterOrderEmail do
  use Phoenix.Swoosh,
    view: RegalocalWeb.Orders.EmailView,
    layout: {RegalocalWeb.LayoutView, :email}

  import RegalocalWeb.PremailHelper
  import RegalocalWeb.Gettext

  def generate(conn, gift, business, token) do
    new()
    |> to({gift.buyer_name, gift.buyer_email})
    |> cc({business.owner_name, business.email})
    |> reply_to({business.owner_name, business.email})
    |> from(from_email())
    |> subject(
      gettext("💳 Instruccions de pagament de la comanda \"%{reference}\"",
        reference: gift.reference
      )
    )
    |> render_body("after_order.html", %{conn: conn, gift: gift, business: business, token: token})
    |> premail
  end

  defp from_email do
    {Application.get_env(:veil, :email_from_name),
     Application.get_env(:veil, :email_from_address)}
  end
end
