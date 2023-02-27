defmodule UptimeChecker.Repo.Migrations.CreateMonitor do
  use Ecto.Migration

  def change do
    create table(:monitor) do
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
      add :muted, :boolean, default: false
      add :status, :integer, default: 1
      add :check_ssl, :boolean, default: false
      add :follow_redirects, :boolean, default: false

      add :next_check_at, :utc_datetime
      add :last_checked_at, :utc_datetime
      add :last_failed_at, :utc_datetime

      add :user_id, references(:user)
      add :monitor_group_id, references(:monitor_group)
      add :prev_id, references(:monitor, on_delete: :delete_all)
      add :organization_id, references(:organization, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:monitor, [:url, :organization_id])

    create index(:monitor, [:on])
    create index(:monitor, [:status])

    create index(:monitor, [:user_id])
    create index(:monitor, [:organization_id])
    create index(:monitor, [:monitor_group_id])

    create index(:monitor, [:next_check_at])
    create index(:monitor, [:last_checked_at, :next_check_at])

    create_prev_id_index =
      "ALTER TABLE monitor ADD CONSTRAINT monitor_unique_previous_id unique (prev_id, organization_id)
    DEFERRABLE INITIALLY DEFERRED"

    drop_prev_id_index = "ALTER TABLE monitor DROP CONSTRAINT monitor_unique_previous_id"
    execute(create_prev_id_index, drop_prev_id_index)
  end
end
