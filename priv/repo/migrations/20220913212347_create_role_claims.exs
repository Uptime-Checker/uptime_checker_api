defmodule UptimeChecker.Repo.Migrations.CreateRoleClaims do
  use Ecto.Migration

  def change do
    create table(:role_claim) do
      add :claim, :string, null: false
      add :role_id, references(:role, on_delete: :delete_all)

      timestamps()
    end

    create index(:role_claim, [:role_id])
    create unique_index(:role_claim, [:claim, :role_id])
  end
end
