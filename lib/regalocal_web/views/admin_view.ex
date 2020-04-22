defmodule RegalocalWeb.AdminLayoutView do
  use RegalocalWeb, :view

  alias RegalocalWeb.BusinessHelpers, as: Business

  def logo(conn) do
    render("logo.html", %{conn: conn})
  end

  def menu_items(%{assigns: %{acceptance: true}} = conn) do
    [
      %{title: gettext("Resum"), path: Routes.admin_dashboard_path(conn, :show), exact: true},
      %{title: gettext("Perfil"), path: Routes.admin_business_path(conn, :edit)},
      %{title: gettext("Cupons"), path: Routes.admin_coupon_path(conn, :index)},
      %{title: gettext("Comandes"), path: Routes.admin_order_path(conn, :index)}
    ]
  end

  def menu_items(conn) do
    [
      %{title: gettext("Completar perfil"), path: Routes.admin_business_path(conn, :edit)}
    ]
  end
end
