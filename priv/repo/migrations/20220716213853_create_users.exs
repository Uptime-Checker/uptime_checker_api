defmodule UptimeChecker.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create_query = "CREATE TYPE provider_name as ENUM(
      'email', 'google', 'apple', 'github'
    )"
    drop_query = "DROP TYPE provider_name"
    execute(create_query, drop_query)

    create table(:users) do
      add :name, :string
      add :email, :string, null: false
      add :password, :string

      add :firebase_uid, :string
      add :provider, :provider_name

      add :organization_id, references(:organizations)

      timestamps()
    end

    create unique_index(:users, [:email])
    create unique_index(:users, [:firebase_uid])

    create index(:users, [:organization_id])
  end
end
