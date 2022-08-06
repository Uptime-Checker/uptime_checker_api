defmodule UptimeChecker.Repo.Migrations.CreateNotifications do
  use Ecto.Migration

  def change do
    create table(:notifications) do
      add :type, :integer
      add :successful, :boolean, default: true, null: false

      add :alarm_id, references(:alarms, on_delete: :delete_all)
      add :monitor_id, references(:monitors, on_delete: :delete_all)
      add :user_contact_id, references(:user_contacts, on_delete: :delete_all)
      add :organization_id, references(:organizations, on_delete: :delete_all)

      timestamps(type: :timestamptz)
    end

    create index(:notifications, [:alarm_id])
    create index(:notifications, [:monitor_id])
    create index(:notifications, [:user_contact_id])
    create index(:notifications, [:organization_id])
    create unique_index(:notifications, [:alarm_id, :type])
  end
end
