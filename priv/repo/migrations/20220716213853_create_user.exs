defmodule UptimeChecker.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:user) do
      add :name, :string, null: false
      add :email, :string, null: false
      add :picture_url, :string
      add :password, :string
      add :payment_customer_id, :string

      add :provider_uid, :string
      add :provider, :integer, default: 1
      add :last_login_at, :utc_datetime, default: fragment("NOW()")

      add :role_id, references(:role)
      add :organization_id, references(:organization, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:user, [:email])
    create unique_index(:user, [:provider_uid])
    create unique_index(:user, [:payment_customer_id])

    create index(:user, [:role_id])
    create index(:user, [:organization_id])
    create index(:user, [:last_login_at])
  end
end
