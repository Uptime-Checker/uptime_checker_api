defmodule UptimeChecker.Repo.Migrations.CreateMonitorAlerts do
  use Ecto.Migration

  def change do
    create table(:monitor_alerts) do
      add :default, :boolean, default: true

      add :user_id, references(:users, on_delete: :delete_all)
      add :monitor_id, references(:monitors, on_delete: :delete_all)
      add :organization_id, references(:organizations, on_delete: :delete_all)
      add :integration_id, references(:monitor_integrations, on_delete: :delete_all)

      timestamps()
    end

    create index(:monitor_alerts, [:user_id])
    create index(:monitor_alerts, [:monitor_id])
    create index(:monitor_alerts, [:integration_id])
    create index(:monitor_alerts, [:organization_id])
  end
end
