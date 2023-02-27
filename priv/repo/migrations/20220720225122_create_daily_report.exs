defmodule UptimeChecker.Repo.Migrations.CreateDailyReport do
  use Ecto.Migration

  def change do
    create table(:daily_report) do
      add :successful_checks, :integer, default: 0
      add :error_checks, :integer, default: 0
      add :downtime, :integer, default: 0
      add :date, :date

      add :monitor_id, references(:monitor, on_delete: :delete_all)
      add :organization_id, references(:organization, on_delete: :delete_all)

      timestamps()
    end

    create index(:daily_report, [:monitor_id])
    create index(:daily_report, [:organization_id])
    create unique_index(:daily_report, [:date, :monitor_id])
  end
end
