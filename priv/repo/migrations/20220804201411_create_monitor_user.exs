defmodule UptimeChecker.Repo.Migrations.CreateMonitorUser do
  use Ecto.Migration

  def change do
    create table(:monitor_user_junction) do
      add :monitor_id, references(:monitors, on_delete: :delete_all)
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create index(:monitor_user_junction, [:monitor_id])
    create index(:monitor_user_junction, [:user_id])
    create unique_index(:monitor_user_junction, [:user_id, :monitor_id])
  end
end
