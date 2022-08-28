defmodule UptimeChecker.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products) do
      add :name, :string, null: false
      add :description, :string
      add :external_id, :string, null: false

      add :tier, :integer, default: 1

      timestamps()
    end

    create unique_index(:products, [:name])
    create unique_index(:products, [:tier])
    create unique_index(:products, [:external_id])
  end
end
