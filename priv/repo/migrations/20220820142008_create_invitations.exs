defmodule UptimeChecker.Repo.Migrations.CreateInvitations do
  use Ecto.Migration

  def change do
    create table(:invitations) do
      add :email, :string, null: false
      add :code, :string, null: false
      add :expires_at, :utc_datetime, null: false
      add :notification_count, :integer, default: 1

      add :invited_by_user_id, references(:users)
      add :role_id, references(:roles)
      add :organization_id, references(:organizations, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:invitations, [:code])
    create unique_index(:invitations, [:email, :organization_id])
    create index(:invitations, [:invited_by_user_id])

    create index(:invitations, [:email])
    create index(:invitations, [:expires_at])

    create index(:invitations, [:role_id])
    create index(:invitations, [:organization_id])
  end
end
