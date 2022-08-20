defmodule UptimeChecker.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products) do
      add :name, :string, null: false
      add :description, :string

      add :tier, :integer, default: 1

      timestamps()
    end

    create unique_index(:products, [:name])
    create unique_index(:products, [:tier])
  end
end
