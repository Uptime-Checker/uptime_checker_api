defmodule UptimeChecker.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string, null: false
      add :email, :string, null: false
      add :picture_url, :string
      add :password, :string
      add :payment_customer_id, :string

      add :provider_uid, :string
      add :provider, :integer, default: 1
      add :last_login_at, :utc_datetime, default: fragment("NOW()")

      add :role_id, references(:roles)
      add :organization_id, references(:organizations, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:users, [:email])
    create unique_index(:users, [:provider_uid])
    create unique_index(:users, [:payment_customer_id])

    create index(:users, [:role_id])
    create index(:users, [:organization_id])
    create index(:users, [:last_login_at])
  end
end
