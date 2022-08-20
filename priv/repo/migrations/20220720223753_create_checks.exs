defmodule UptimeChecker.Repo.Migrations.CreateChecks do
  use Ecto.Migration

  def change do
    create table(:checks) do
      add :success, :boolean, default: false, null: false
      add :duration, :integer, default: 0

      add :region_id, references(:regions)
      add :monitor_id, references(:monitors, on_delete: :delete_all)
      add :organization_id, references(:organizations, on_delete: :delete_all)

      timestamps()
    end

    create index(:checks, [:region_id])
    create index(:checks, [:monitor_id])
    create index(:checks, [:organization_id])
  end
end
