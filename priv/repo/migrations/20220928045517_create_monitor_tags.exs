defmodule UptimeChecker.Repo.Migrations.CreateMonitorTags do
  use Ecto.Migration

  def change do
    create table(:monitor_tags) do
      add :name, :string, null: false

      add :monitor_id, references(:monitors, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:monitor_tags, [:name, :monitor_id])
    create index(:monitor_tags, [:monitor_id])
  end
end
