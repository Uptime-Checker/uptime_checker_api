defmodule UptimeChecker.Repo.Migrations.CreateMonitorGroup do
  use Ecto.Migration

  def change do
    create table(:monitor_group) do
      add :name, :string, null: false

      add :organization_id, references(:organization, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:monitor_group, [:name, :organization_id])
    create index(:monitor_group, [:organization_id])
  end
end
