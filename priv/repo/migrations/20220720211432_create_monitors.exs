defmodule UptimeChecker.Repo.Migrations.CreateMonitors do
  use Ecto.Migration

  def change do
    create table(:monitors) do
      add :name, :string, null: false
      add :url, :string, null: false
      add :method, :integer, default: 1
      add :interval, :integer, default: 300
      add :timeout, :integer, default: 5
      add :type, :integer, default: 1

      add :body, :text
      add :body_format, :integer, default: 1
      add :headers, :map, default: %{}
      add :username, :text
      add :password, :text

      add :on, :boolean, default: true
      add :status, :integer, default: 1
      add :check_ssl, :boolean, default: false
      add :follow_redirects, :boolean, default: false

      add :resolve_threshold, :integer, default: 1
      add :error_threshold, :integer, default: 1
      add :region_threshold, :integer, default: 1

      add :last_checked_at, :utc_datetime
      add :last_failed_at, :utc_datetime

      add :user_id, references(:users)
      add :monitor_group_id, references(:monitor_groups)
      add :prev_id, references(:monitors, on_delete: :delete_all)
      add :organization_id, references(:organizations, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:monitors, [:url, :organization_id])

    create index(:monitors, [:on])
    create index(:monitors, [:status])

    create index(:monitors, [:user_id])
    create index(:monitors, [:organization_id])
    create index(:monitors, [:monitor_group_id])

    create_prev_id_index =
      "ALTER TABLE monitors ADD CONSTRAINT monitors_unique_previous_id unique (prev_id, organization_id)
    DEFERRABLE INITIALLY DEFERRED"

    drop_prev_id_index = "ALTER TABLE monitors DROP CONSTRAINT monitors_unique_previous_id"
    execute(create_prev_id_index, drop_prev_id_index)
  end
end
