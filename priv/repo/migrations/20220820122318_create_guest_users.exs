defmodule UptimeChecker.Repo.Migrations.CreateGuestUsers do
  use Ecto.Migration

  def change do
    create table(:guest_users) do
      add :email, :string, null: false
      add :code, :string, null: false
      add :expires_at, :utc_datetime, null: false

      timestamps(type: :timestamptz)
    end

    create unique_index(:guest_users, [:code])
    create index(:guest_users, [:expires_at])
  end
end
