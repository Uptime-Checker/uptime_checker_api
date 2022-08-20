defmodule UptimeChecker.Repo.Migrations.CreateInvitations do
  use Ecto.Migration

  def change do
    create table(:invitations) do
      add :email, :string, null: false
      add :code, :string, null: false
      add :expires_at, :utc_datetime, null: false

      add :role_id, references(:roles)
      add :organization_id, references(:organizations, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:invitations, [:code])
    create unique_index(:invitations, [:organization_id, :email])

    create index(:invitations, [:email])
    create index(:invitations, [:expires_at])

    create index(:invitations, [:role_id])
    create index(:invitations, [:organization_id])
  end
end
