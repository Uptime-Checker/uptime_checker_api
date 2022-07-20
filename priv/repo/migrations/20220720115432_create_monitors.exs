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
      add :status_codes, {:array, :integer}, default: []
      add :interval, :integer, default: 60
      add :timeout, :integer, default: 5

      add :body, :string
      add :contains, :string
      add :headers, :map, default: %{}
      add :on, :boolean, default: true
      add :follow_redirects, :boolean, default: false

      add :resolve_threshold, :integer, default: 1
      add :error_threshold, :integer, default: 1

      add :last_checked_at, :utc_datetime
      add :last_failed_at, :utc_datetime
      add :deleted_at, :utc_datetime

      add :user_id, references(:users)
      add :organization_id, references(:organizations)

      timestamps()
    end

    create unique_index(:monitors, [:url])

    create index(:monitors, [:organization_id])
  end
end
