defmodule UptimeChecker.Repo.Migrations.CreateMonitorRegions do
  use Ecto.Migration

  def change do
    create table(:monitor_region_junction) do
      add :down, :boolean, default: false
      add :last_checked_at, :utc_datetime

      add :monitor_id, references(:monitors, on_delete: :delete_all)
      add :region_id, references(:regions, on_delete: :delete_all)

      timestamps()
    end

    create index(:monitor_region_junction, [:monitor_id])
    create index(:monitor_region_junction, [:region_id])
    create index(:monitor_region_junction, [:last_checked_at])
    create unique_index(:monitor_region_junction, [:region_id, :monitor_id])
  end
end
