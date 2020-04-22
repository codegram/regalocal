defmodule Regalocal.Repo.Migrations.FormatWebsiteUrl do
  use Ecto.Migration
  import Ecto.Changeset, only: [change: 2]
  alias Regalocal.Admin.Business
  alias Regalocal.Repo

  def change do
    businesses = Repo.all(Business)

    Enum.each(businesses, fn business ->
      website =
        if String.starts_with?(business.website, ["http://", "https://"]) do
          business.website
        else
          "http://" <> business.website
        end

      Repo.update!(change(business, website: website))
    end)
  end
end
