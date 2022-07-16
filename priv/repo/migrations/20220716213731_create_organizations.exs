defmodule UptimeChecker.Repo.Migrations.CreateOrganizations do
  use Ecto.Migration

  def change do
    create table(:organizations) do
      add :name, :string
      add :key, :string

      timestamps()
    end
  end
end
