defmodule RegalocalWeb.Veil.BusinessView do
  use RegalocalWeb, :view
  import RegalocalWeb.PublicLayoutHelpers

  def title(:new, _assigns), do: gettext("Alta com a comerç")
end
