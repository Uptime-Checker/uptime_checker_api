defmodule UptimeChecker.Repo.Migrations.CreateMonitorNotification do
  use Ecto.Migration

  def change do
    create table(:monitor_notification) do
      add :type, :integer
      add :successful, :boolean, default: true, null: false

      add :alarm_id, references(:alarm, on_delete: :delete_all)
      add :monitor_id, references(:monitor, on_delete: :delete_all)
      add :user_contact_id, references(:user_contact, on_delete: :delete_all)
      add :organization_id, references(:organization, on_delete: :delete_all)
      add :integration_id, references(:monitor_integration, on_delete: :delete_all)

      timestamps()
    end

    create index(:monitor_notification, [:alarm_id])
    create index(:monitor_notification, [:monitor_id])
    create index(:monitor_notification, [:user_contact_id])
    create index(:monitor_notification, [:organization_id])
    create index(:monitor_notification, [:integration_id])

    create unique_index(:monitor_notification, [
             :alarm_id,
             :type,
             :user_contact_id,
             :integration_id
           ])
  end
end
