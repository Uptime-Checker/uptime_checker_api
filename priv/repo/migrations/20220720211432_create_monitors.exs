defmodule UptimeChecker.Repo.Migrations.CreateMonitors do
  use Ecto.Migration

  def change do
    create_query = "CREATE TYPE method_name as ENUM(
      'GET', 'POST', 'PUT', 'DELETE', 'PATCH'
    )"
    drop_query = "DROP TYPE method_name"
    execute(create_query, drop_query)

    create table(:monitors) do
      add :name, :string
      add :url, :string, null: false
      add :method, :method_name, null: false
      add :interval, :integer, default: 60
      add :timeout, :integer, default: 5
      add :type, :integer, default: 1

      add :body, :string
      add :contains, :string
      add :headers, :map, default: %{}
      add :on, :boolean, default: true
      add :down, :boolean, default: false
      add :check_ssl, :boolean, default: false
      add :follow_redirects, :boolean, default: false

      add :resolve_threshold, :integer, default: 1
      add :error_threshold, :integer, default: 1
      add :region_threshold, :integer, default: 1

      add :last_checked_at, :utc_datetime
      add :last_failed_at, :utc_datetime

      add :user_id, references(:users)
      add :prev_id, references(:monitors, on_delete: :delete_all)
      add :organization_id, references(:organizations, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:monitors, [:url, :organization_id])

    create index(:monitors, [:user_id])
    create index(:monitors, [:organization_id])

    create_prev_id_index =
      "ALTER TABLE monitors ADD CONSTRAINT monitors_unique_previous_id unique (prev_id, organization_id)
    DEFERRABLE INITIALLY DEFERRED"

    drop_prev_id_index = "ALTER TABLE monitors DROP CONSTRAINT monitors_unique_previous_id"
    execute(create_prev_id_index, drop_prev_id_index)
  end
end
