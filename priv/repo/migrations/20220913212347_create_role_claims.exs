defmodule UptimeChecker.Repo.Migrations.CreateRoleClaims do
  use Ecto.Migration

  def change do
    create table(:role_claim_junction) do
      add :role_id, references(:roles, on_delete: :delete_all)
      add :claim_id, references(:claims, on_delete: :delete_all)

      timestamps()
    end

    create index(:role_claim_junction, [:role_id])
    create index(:role_claim_junction, [:claim_id])
    create unique_index(:role_claim_junction, [:claim_id, :role_id])
  end
end
