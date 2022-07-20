defmodule UptimeChecker.Repo.Migrations.CreateMonitorStatusCodeTable do
  use Ecto.Migration

  def change do
    create table(:monitor_status_code_junction) do
      add :monitor_id, references(:monitors, on_delete: :delete_all)
      add :status_code_id, references(:status_codes, on_delete: :delete_all)

      timestamps()
    end

    create index(:monitor_status_code_junction, [:monitor_id])
    create index(:monitor_status_code_junction, [:status_code_id])
    create unique_index(:monitor_status_code_junction, [:monitor_id, :status_code_id])
  end
end
