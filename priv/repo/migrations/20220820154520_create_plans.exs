defmodule UptimeChecker.Repo.Migrations.CreatePlans do
  use Ecto.Migration

  def change do
    create table(:plans) do
      add :price, :float, null: false
      add :type, :integer, default: 1

      add :product_id, references(:products, on_delete: :delete_all)

      timestamps()
    end

    create index(:plans, [:product_id])
  end
end
