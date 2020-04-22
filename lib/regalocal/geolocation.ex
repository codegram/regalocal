defmodule Regalocal.Geolocation do
  defstruct lat: nil, lon: nil, address: nil, country_code: nil

  @country_codes %{
    "Spain" => "ES"
  }

  @countries Map.keys(@country_codes)

  def locate(raw_address) when is_binary(raw_address) do
    locate(raw_address, "Spain")
  end

  def locate(raw_address, country) when is_binary(raw_address) and country in @countries do
    case geocode(raw_address <> ", " <> country) do
      {:ok, %Regalocal.Geolocation{country_code: code} = geolocation} ->
        if code == @country_codes[country] do
          {:ok, geolocation}
        else
          {:error, "Address is not in #{country}"}
        end

      otherwise ->
        otherwise
    end
  end

  def locate(coordinates) when is_tuple(coordinates) do
    geocode(coordinates, coordinates)
  end

  defp geocode(args) do
    geocode(args, nil)
  end

  defp geocode(args, coordinates) do
    case Geocoder.call(args) do
      {:ok,
       %Geocoder.Coords{
         lat: detected_lat,
         lon: detected_lon,
         location: %Geocoder.Location{
           formatted_address: address,
           country_code: country_code
         }
       }} ->
        {lat, lon} =
          if coordinates do
            coordinates
          else
            {detected_lat, detected_lon}
          end

        {:ok,
         %Regalocal.Geolocation{lat: lat, lon: lon, address: address, country_code: country_code}}

      {:error, _} ->
        {:error, "Could not geolocate " <> args}
    end
  end

  def to_geopoint(%{lat: lat, lon: lon}) do
    %Geo.Point{coordinates: {lat, lon}, srid: 4326}
  end

  def to_geopoint(%{query: query}) do
    case locate(query) do
      {:ok, geolocation} -> {:ok, to_geopoint(geolocation)}
      otherwise -> otherwise
    end
  end
end
