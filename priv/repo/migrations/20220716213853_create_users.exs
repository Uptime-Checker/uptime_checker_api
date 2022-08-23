defmodule UptimeChecker.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create_query = "CREATE TYPE provider_name as ENUM(
      'email', 'google', 'apple', 'github'
    )"
    drop_query = "DROP TYPE provider_name"
    execute(create_query, drop_query)

    create table(:users) do
      add :name, :string, null: false
      add :email, :string, null: false
      add :picture_url, :string
      add :password, :string

      add :firebase_uid, :string
      add :provider, :provider_name, null: false
      add :last_login_at, :utc_datetime, default: fragment("NOW()")

      add :role_id, references(:roles)
      add :organization_id, references(:organizations, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:users, [:email])
    create unique_index(:users, [:firebase_uid])

    create index(:users, [:role_id])
    create index(:users, [:organization_id])
    create index(:users, [:last_login_at])
  end
end
