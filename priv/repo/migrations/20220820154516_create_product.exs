defmodule UptimeChecker.Repo.Migrations.CreateProduct do
  use Ecto.Migration

  def change do
    create table(:product) do
      add :name, :string, null: false
      add :description, :string
      add :external_id, :string

      add :tier, :integer, default: 1

      timestamps()
    end

    create unique_index(:product, [:name])
    create unique_index(:product, [:tier])
    create unique_index(:product, [:external_id])
  end
end
