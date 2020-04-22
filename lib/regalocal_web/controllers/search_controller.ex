defmodule RegalocalWeb.SearchController do
  use RegalocalWeb, :controller
  alias Regalocal.Search
  alias Regalocal.Geolocation

  @limit_km 100

  def index(conn, %{"latitude" => latitude, "longitude" => longitude}) do
    find_businesses_near(conn, [{String.to_float(latitude), String.to_float(longitude)}])
  end

  def index(conn, %{"q" => query}) do
    find_businesses_near(conn, [query, "Spain"])
  end

  defp find_businesses_near(conn, args) do
    case apply(Geolocation, :locate, args) do
      {:ok, geolocation} ->
        businesses = Search.find_businesses_near!(Geolocation.to_geopoint(geolocation), @limit_km)

        conn
        |> assign(:businesses, businesses)
        |> assign(:address, geolocation.address)
        |> assign(:limit_km, @limit_km)
        |> render("index.html")

      {:error, error} ->
        conn
        |> put_flash(:error, error)
        |> assign(:businesses, [])
        |> render("index.html")
    end
  end
end
