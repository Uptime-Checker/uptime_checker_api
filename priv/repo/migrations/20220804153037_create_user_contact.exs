defmodule UptimeChecker.Repo.Migrations.CreateUserContact do
  use Ecto.Migration

  def change do
    create table(:user_contact) do
      add :email, :string
      add :number, :string
      add :mode, :integer
      add :device_id, :string
      add :verification_code, :string
      add :verification_code_expires_at, :utc_datetime
      add :verified, :boolean, default: false, null: false
      add :subscribed, :boolean, default: true, null: false
      add :bounce_count, :integer, default: 0

      add :user_id, references(:user, on_delete: :delete_all)

      timestamps()
    end

    create index(:user_contact, [:user_id])
    create unique_index(:user_contact, [:email, :verified])
    create unique_index(:user_contact, [:number, :verified])
    create unique_index(:user_contact, [:device_id])
  end
end
