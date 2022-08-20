defmodule UptimeChecker.Repo.Migrations.CreateAlarms do
  use Ecto.Migration

  def change do
    create table(:alarms) do
      add :ongoing, :boolean
      add :resolved_at, :utc_datetime

      add :triggered_by_check_id, references(:checks)
      add :resolved_by_check_id, references(:checks)

      add :monitor_id, references(:monitors, on_delete: :delete_all)
      add :organization_id, references(:organizations, on_delete: :delete_all)

      timestamps()
    end

    create index(:alarms, [:monitor_id])
    create index(:alarms, [:organization_id])
    create unique_index(:alarms, [:triggered_by_check_id])

    # Partial index
    create unique_index(:alarms, [:monitor_id, :ongoing],
             name: :uq_monitor_on_alarm,
             where: "ongoing = TRUE"
           )
  end
end
