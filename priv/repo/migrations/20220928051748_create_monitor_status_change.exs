defmodule UptimeChecker.Repo.Migrations.CreateMonitorStatusChange do
  use Ecto.Migration

  def change do
    create table(:monitor_status_changes) do
      add :status, :integer, default: 1
      add :changed_at, :utc_datetime

      add :monitor_id, references(:monitors, on_delete: :delete_all)
    end

    create unique_index(:monitor_status_changes, [:status, :monitor_id])
  end
end
