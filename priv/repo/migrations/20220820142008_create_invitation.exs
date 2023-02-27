defmodule UptimeChecker.Repo.Migrations.CreateInvitation do
  use Ecto.Migration

  def change do
    create table(:invitation) do
      add :email, :string, null: false
      add :code, :string, null: false
      add :expires_at, :utc_datetime, null: false
      add :notification_count, :integer, default: 1

      add :invited_by_user_id, references(:user)
      add :role_id, references(:role)
      add :organization_id, references(:organization, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:invitation, [:code])
    create unique_index(:invitation, [:email, :organization_id])
    create index(:invitation, [:invited_by_user_id])

    create index(:invitation, [:email])
    create index(:invitation, [:expires_at])

    create index(:invitation, [:role_id])
    create index(:invitation, [:organization_id])
  end
end
