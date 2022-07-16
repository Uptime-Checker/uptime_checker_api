defmodule UptimeChecker.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :email, :string
      add :password_hash, :string
      add :firebase_uid, :string
      add :provider, :integer

      timestamps()
    end
  end
end
