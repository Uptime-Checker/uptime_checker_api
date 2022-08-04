defmodule UptimeChecker.Repo.Migrations.CreateNotifications do
  use Ecto.Migration

  def change do
    create table(:notifications) do
      add :alarm_id, references(:alarms, on_delete: :delete_all)
      add :monitor_id, references(:monitors, on_delete: :delete_all)
      add :user_contact_id, references(:user_contacts, on_delete: :delete_all)
      add :organization_id, references(:organizations, on_delete: :delete_all)
      add :type, :integer

      timestamps(type: :timestamptz)
    end

    create index(:notifications, [:alarm_id])
    create index(:notifications, [:monitor_id])
    create index(:notifications, [:user_contact_id])
    create index(:notifications, [:organization_id])
  end
end
