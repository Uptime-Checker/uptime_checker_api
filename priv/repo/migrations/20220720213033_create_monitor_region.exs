defmodule UptimeChecker.Repo.Migrations.CreateMonitorRegion do
  use Ecto.Migration

  def change do
    create table(:monitor_region_junction) do
      add :monitor_id, references(:monitors, on_delete: :delete_all)
      add :region_id, references(:regions, on_delete: :delete_all)

      timestamps()
    end

    create index(:monitor_region_junction, [:monitor_id])
    create index(:monitor_region_junction, [:region_id])
    create unique_index(:monitor_region_junction, [:monitor_id, :region_id])
  end
end
