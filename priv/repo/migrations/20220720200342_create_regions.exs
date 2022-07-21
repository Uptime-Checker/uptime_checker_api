defmodule UptimeChecker.Repo.Migrations.CreateRegions do
  use Ecto.Migration

  def change do
    create table(:regions) do
      add :name, :string, null: false
      add :key, :string, null: false
      add :ip_address, :string

      timestamps(type: :timestamptz)
    end
  end
end
