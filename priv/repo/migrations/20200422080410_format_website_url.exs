defmodule Regalocal.Repo.Migrations.FormatWebsiteUrl do
  use Ecto.Migration
  import Ecto.Changeset, only: [change: 2]
  alias Regalocal.Admin.Business
  alias Regalocal.Repo
  import Ecto.Query

  def change do
    businesses = Repo.all(from(b in Business, where: not is_nil(b.website)))

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
