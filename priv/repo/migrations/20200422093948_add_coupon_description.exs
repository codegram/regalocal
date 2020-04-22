defmodule Regalocal.Repo.Migrations.AddCouponDescription do
  use Ecto.Migration

  def change do
    alter table(:coupons) do
      add(:description, :text)
    end
  end
end
