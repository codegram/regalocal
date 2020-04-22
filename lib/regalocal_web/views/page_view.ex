defmodule RegalocalWeb.PageView do
  use RegalocalWeb, :view
  import RegalocalWeb.PublicLayoutHelpers
  import RegalocalWeb.Gettext

  def title(:index, _assigns) do
    gettext("Regala solidaritat al comerç local")
  end

  def title(:about, _assigns) do
    gettext("Sobre nosaltres")
  end

  def title(:cookies, _assigns) do
    gettext("Política de Cookies")
  end

  def title(:privacy, _assigns) do
    gettext("Política de Privacitat")
  end

  def title(:terms, _assigns) do
    gettext("Avís Legal")
  end
end
