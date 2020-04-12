defmodule RegalocalWeb.SearchView do
  use RegalocalWeb, :view
  import RegalocalWeb.PublicLayoutHelpers
  alias RegalocalWeb.BusinessHelpers, as: Business

  def title(:index, _assigns) do
    "Cercant comerços al teu voltant"
  end
end
