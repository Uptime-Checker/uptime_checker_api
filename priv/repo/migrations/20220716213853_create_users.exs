defmodule UptimeChecker.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :email, :string, null: false
      add :password, :string

      add :firebase_uid, :string
      add :provider, :integer

      add :organization_id, references(:organizations)

      timestamps()
    end

    create unique_index(:users, [:email])
    create unique_index(:users, [:firebase_uid])

    create index(:users, [:organization_id])
  end
end
