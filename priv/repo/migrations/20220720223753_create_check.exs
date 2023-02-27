defmodule UptimeChecker.Repo.Migrations.CreateCheck do
  use Ecto.Migration

  def change do
    create table(:check) do
      add :status_code, :integer
      add :duration, :integer, default: 0
      add :success, :boolean, default: false, null: false

      add :region_id, references(:region)
      add :monitor_id, references(:monitor, on_delete: :delete_all)
      add :organization_id, references(:organization, on_delete: :delete_all)

      timestamps()
    end

    create index(:check, [:region_id])
    create index(:check, [:monitor_id])
    create index(:check, [:organization_id])
  end
end
