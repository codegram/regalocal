defmodule RegalocalWeb.Orders.PaymentReceivedEmail do
  use Phoenix.Swoosh,
    view: RegalocalWeb.Orders.EmailView,
    layout: {RegalocalWeb.LayoutView, :email}

  import RegalocalWeb.PremailHelper
  import RegalocalWeb.Gettext

  def generate(conn, gift, business) do
    new()
    |> to({gift.buyer_name, gift.buyer_email})
    |> reply_to({business.owner_name, business.email})
    |> from(from_email())
    |> subject(gettext("👍 Pagament rebut: \"%{reference}\"", reference: gift.reference))
    |> render_body("payment_received.html", %{conn: conn, gift: gift, business: business})
    |> premail
  end

  defp from_email do
    {Application.get_env(:veil, :email_from_name),
     Application.get_env(:veil, :email_from_address)}
  end
end
