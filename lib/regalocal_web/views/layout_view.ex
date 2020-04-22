defmodule RegalocalWeb.LayoutView do
  use RegalocalWeb, :view

  def title(assigns) do
    title = forward_to_view(:title, assigns)
    if title, do: "#{title} - RegaLocal", else: "RegaLocal"
  end

  def meta_description(assigns) do
    forward_to_view(:meta_description, assigns) ||
      gettext(
        "Ajuda als comerços i petits negocis a fer front a la crisi causada pel 🦠 COVID-19 i al mateix temps regala solidaritat als qui t'estimes."
      )
  end

  def logo(conn) do
    render("logo.html", %{conn: conn})
  end

  def menu_items(conn) do
    [
      %{title: gettext("Sobre nosaltres"), path: Routes.page_path(conn, :about)},
      %{title: gettext("Preguntes Freqüents"), path: Routes.faq_path(conn, :index)}
    ]
  end

  defp forward_to_view(name, assigns) do
    try do
      apply(assigns[:view_module], name, [Phoenix.Controller.action_name(assigns[:conn]), assigns])
    rescue
      UndefinedFunctionError -> nil
      FunctionClauseError -> nil
    end
  end
end
