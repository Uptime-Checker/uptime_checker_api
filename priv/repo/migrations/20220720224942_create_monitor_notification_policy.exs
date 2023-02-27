defmodule UptimeChecker.Repo.Migrations.CreateMonitorNotificationPolicy do
  use Ecto.Migration

  def change do
    create table(:monitor_notification_policy) do
      add :user_id, references(:user, on_delete: :delete_all)
      add :monitor_id, references(:monitor, on_delete: :delete_all)
      add :organization_id, references(:organization, on_delete: :delete_all)
      add :integration_id, references(:monitor_integration, on_delete: :delete_all)

      timestamps()
    end

    create index(:monitor_notification_policy, [:user_id])
    create index(:monitor_notification_policy, [:monitor_id])
    create index(:monitor_notification_policy, [:integration_id])
    create index(:monitor_notification_policy, [:organization_id])

    create unique_index(:monitor_notification_policy, [
             :user_id,
             :monitor_id,
             :integration_id,
             :organization_id
           ])
  end
end
