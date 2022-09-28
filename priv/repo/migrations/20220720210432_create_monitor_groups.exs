defmodule UptimeChecker.Repo.Migrations.CreateMonitorGroups do
  use Ecto.Migration

  def change do
    create table(:monitor_groups) do
      add :name, :string, null: false

      add :organization_id, references(:organizations, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:monitor_groups, [:name, :organization_id])
    create index(:monitor_groups, [:organization_id])
  end
end
