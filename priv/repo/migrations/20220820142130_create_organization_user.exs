defmodule UptimeChecker.Repo.Migrations.CreateOrganizationUser do
  use Ecto.Migration

  def change do
    create table(:organization_user_junction) do
      add :role_id, references(:roles)
      add :user_id, references(:users, on_delete: :delete_all)
      add :organization_id, references(:organizations, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:organization_user_junction, [:user_id, :organization_id])

    create index(:organization_user_junction, [:role_id])
    create index(:organization_user_junction, [:user_id])
    create index(:organization_user_junction, [:organization_id])
  end
end
