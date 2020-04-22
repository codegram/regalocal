defmodule RegalocalWeb.PageController do
  use RegalocalWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def terms(conn, _params) do
    render(conn, "terms.html")
  end

  def privacy(conn, _params) do
    render(conn, "privacy.html")
  end

  def cookies(conn, _params) do
    render(conn, "cookies.html")
  end

  def about(conn, _params) do
    render(conn, "about.html")
  end
end

""
