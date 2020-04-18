defmodule RegalocalWeb.SitemapController do
  alias Regalocal.Repo
  alias Regalocal.Admin.Business

  use RegalocalWeb, :controller

  def show(conn, _params) do
    businesses =
      Business
      |> where(accepted_terms: true)
      |> Repo.all()

    conn
    |> put_resp_content_type("text/xml")
    |> render("show.xml", businesses: businesses)
  end
end
