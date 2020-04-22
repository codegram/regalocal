defmodule RegalocalWeb.Admin.OrderView do
  use RegalocalWeb, :view

  alias Regalocal.Admin
  alias RegalocalWeb.AdminLayoutHelpers, as: AdminHelpers
  alias Regalocal.Orders.Gift

  def status(%Gift{status: :pending_payment}), do: gettext("Pendent de pagament")
  def status(%Gift{status: :paid}), do: gettext("Pagada")
  def status(%Gift{status: :payment_confirmed}), do: gettext("Pagament confirmat")
  def status(%Gift{status: :redeemed}), do: gettext("Bescanviat")

  def status_pill(%Gift{} = order) do
    render("status.html", %{order: order, formatted_status: status(order)})
  end
end
