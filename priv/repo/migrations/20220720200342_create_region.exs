defmodule UptimeChecker.Repo.Migrations.CreateRegion do
  use Ecto.Migration

  def change do
    create table(:region) do
      add :name, :string, null: false
      add :key, :string, null: false
      add :ip_address, :string
      add :default, :boolean, default: false

      timestamps()
    end

    create unique_index(:region, [:key])
  end
end
