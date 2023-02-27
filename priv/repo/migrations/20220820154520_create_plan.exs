defmodule UptimeChecker.Repo.Migrations.CreatePlan do
  use Ecto.Migration

  def change do
    create table(:plan) do
      add :price, :float, null: false
      add :type, :integer, default: 1
      add :external_id, :string

      add :product_id, references(:product, on_delete: :delete_all)

      timestamps()
    end

    create index(:plan, [:product_id])
    create unique_index(:plan, [:external_id])
    create unique_index(:plan, [:price, :type])
  end
end
