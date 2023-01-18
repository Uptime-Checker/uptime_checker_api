defmodule UptimeChecker.Repo.Migrations.CreateOrganizationUsers do
  use Ecto.Migration

  def change do
    create table(:organization_user_junction) do
      add :status, :integer, default: 1

      add :role_id, references(:roles)
      add :user_id, references(:users, on_delete: :delete_all)
      add :organization_id, references(:organizations, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:organization_user_junction, [:user_id, :organization_id])

    create index(:organization_user_junction, [:role_id])
    create index(:organization_user_junction, [:user_id])
    create index(:organization_user_junction, [:organization_id])

    # Partial index
    create unique_index(:organization_user_junction, [:role_id, :user_id],
             name: :uq_superadmin_on_org_user,
             where: "role_id = 1"
           )
  end
end
