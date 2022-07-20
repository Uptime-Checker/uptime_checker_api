defmodule UptimeChecker.Repo.Migrations.CreateAlarms do
  use Ecto.Migration

  def change do
    create table(:alarms) do
      add :ongoing, :boolean
      add :resolved_at, :utc_datetime

      # add triggered_by_check_id
      # add tresolved_by_check_id

      add :monitor_id, references(:monitors, on_delete: :delete_all)
      add :organization_id, references(:organizations, on_delete: :delete_all)

      timestamps()
    end

    create index(:checks, [:monitor_id])
    create index(:checks, [:organization_id])
  end
end
