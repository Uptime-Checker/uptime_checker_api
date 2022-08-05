defmodule UptimeChecker.Repo.Migrations.CreateUserContacts do
  use Ecto.Migration

  def change do
    create table(:user_contacts) do
      add :email, :string
      add :number, :string
      add :mode, :integer
      add :device_id, :string
      add :verified, :boolean, default: false, null: false
      add :subscribed, :boolean, default: true, null: false

      add :user_id, references(:users, on_delete: :delete_all)

      timestamps(type: :timestamptz)
    end

    create index(:user_contacts, [:user_id])
    create unique_index(:user_contacts, [:email, :verified])
    create unique_index(:user_contacts, [:number, :verified])
    create unique_index(:user_contacts, [:device_id])
  end
end
