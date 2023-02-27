defmodule UptimeChecker.Repo.Migrations.CreateMonitorStatusChange do
  use Ecto.Migration

  def change do
    create table(:monitor_status_change) do
      add :status, :integer, default: 1
      add :changed_at, :utc_datetime

      add :monitor_id, references(:monitor, on_delete: :delete_all)

      timestamps()
    end

    create index(:monitor_status_change, [:monitor_id])
  end
end
