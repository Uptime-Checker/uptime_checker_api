defmodule UptimeChecker.Repo.Migrations.CreateOrganizations do
  use Ecto.Migration

  def change do
    create table(:organizations) do
      add :name, :string, null: false
      add :slug, :string, null: false

      timestamps(type: :timestamptz)
    end

    create unique_index(:organizations, [:slug])
  end
end
