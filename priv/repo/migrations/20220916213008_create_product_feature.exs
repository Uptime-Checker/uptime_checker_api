defmodule UptimeChecker.Repo.Migrations.CreateProductFeatures do
  use Ecto.Migration

  def change do
    create table(:product_feature) do
      add :count, :integer, default: 1

      add :product_id, references(:product, on_delete: :delete_all)
      add :feature_id, references(:feature, on_delete: :delete_all)

      timestamps()
    end

    create index(:product_feature, [:product_id])
    create index(:product_feature, [:feature_id])
    create unique_index(:product_feature, [:product_id, :feature_id])
  end
end
