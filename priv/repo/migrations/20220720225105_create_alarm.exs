defmodule UptimeChecker.Repo.Migrations.CreateAlarm do
  use Ecto.Migration

  def change do
    create table(:alarm) do
      add :ongoing, :boolean
      add :resolved_at, :utc_datetime

      add :triggered_by_check_id, references(:check)
      add :resolved_by_check_id, references(:check)

      add :monitor_id, references(:monitor, on_delete: :delete_all)
      add :organization_id, references(:organization, on_delete: :delete_all)

      timestamps()
    end

    create index(:alarm, [:monitor_id])
    create index(:alarm, [:organization_id])
    create unique_index(:alarm, [:triggered_by_check_id])

    # Partial index
    create unique_index(:alarm, [:monitor_id, :ongoing],
             name: :uq_monitor_on_alarm,
             where: "ongoing = TRUE"
           )
  end
end
