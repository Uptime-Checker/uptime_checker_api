defmodule UptimeChecker.Repo.Migrations.CreateMonitorRegion do
  use Ecto.Migration

  def change do
    create table(:monitor_region) do
      add :down, :boolean, default: false
      add :last_checked_at, :utc_datetime

      add :monitor_id, references(:monitor, on_delete: :delete_all)
      add :region_id, references(:region, on_delete: :delete_all)

      timestamps()
    end

    create index(:monitor_region, [:monitor_id])
    create index(:monitor_region, [:region_id])
    create index(:monitor_region, [:last_checked_at])
    create unique_index(:monitor_region, [:region_id, :monitor_id])
  end
end
