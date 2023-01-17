defmodule UptimeChecker.Repo.Migrations.CreateProductFeatures do
  use Ecto.Migration

  def change do
    create table(:product_feature_junction) do
      add :count, :integer, default: 1

      add :product_id, references(:products, on_delete: :delete_all)
      add :feature_id, references(:features, on_delete: :delete_all)

      timestamps()
    end

    create index(:product_feature_junction, [:product_id])
    create index(:product_feature_junction, [:feature_id])
    create unique_index(:product_feature_junction, [:product_id, :feature_id])
  end
end
