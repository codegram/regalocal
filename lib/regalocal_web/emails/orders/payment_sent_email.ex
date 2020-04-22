defmodule RegalocalWeb.Orders.PaymentSentEmail do
  use Phoenix.Swoosh,
    view: RegalocalWeb.Orders.EmailView,
    layout: {RegalocalWeb.LayoutView, :email}

  import RegalocalWeb.PremailHelper
  import RegalocalWeb.Gettext

  def generate(conn, gift, business) do
    new()
    |> to({business.owner_name, business.email})
    |> from(from_email())
    |> subject(gettext("✅ Pagament realitzat: \"%{reference}\"", reference: gift.reference))
    |> render_body("payment_sent.html", %{conn: conn, gift: gift, business: business})
    |> premail
  end

  defp from_email do
    {Application.get_env(:veil, :email_from_name),
     Application.get_env(:veil, :email_from_address)}
  end
end
