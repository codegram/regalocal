defmodule RegalocalWeb.FaqView do
  use RegalocalWeb, :view
  import RegalocalWeb.PublicLayoutHelpers

  def title(:index, _assigns) do
    gettext("Preguntes Freqüents")
  end
end
