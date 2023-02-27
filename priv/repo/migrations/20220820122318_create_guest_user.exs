defmodule UptimeChecker.Repo.Migrations.CreateGuestUser do
  use Ecto.Migration

  def change do
    create table(:guest_user) do
      add :email, :string, null: false
      add :code, :string, null: false
      add :expires_at, :utc_datetime, null: false

      timestamps()
    end

    create unique_index(:guest_user, [:code])
    create index(:guest_user, [:expires_at])
  end
end
