defmodule UptimeChecker.Repo.Migrations.CreateDailyReports do
  use Ecto.Migration

  def change do
    create table(:daily_reports) do
      add :successful_checks, :integer, default: 0
      add :error_checks, :integer, default: 0
      add :downtime, :integer, default: 0
      add :date, :date

      add :monitor_id, references(:monitors, on_delete: :delete_all)
      add :organization_id, references(:organizations, on_delete: :delete_all)

      timestamps()
    end

    create index(:daily_reports, [:monitor_id])
    create index(:daily_reports, [:organization_id])
    create unique_index(:daily_reports, [:date, :monitor_id])
  end
end
