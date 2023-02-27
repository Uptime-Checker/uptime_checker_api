defmodule UptimeChecker.Repo.Migrations.CreateMonitorAlarmPolicy do
  use Ecto.Migration

  def change do
    create table(:monitor_alarm_policy) do
      add :reason, :string
      add :threshold, :integer, default: 0

      add :monitor_id, references(:monitor, on_delete: :delete_all)
      add :organization_id, references(:organization, on_delete: :delete_all)

      timestamps()
    end

    create index(:monitor_alarm_policy, [:monitor_id])
    create index(:monitor_alarm_policy, [:organization_id])

    create unique_index(:monitor_alarm_policy, [
             :reason,
             :monitor_id,
             :organization_id
           ])
  end
end
