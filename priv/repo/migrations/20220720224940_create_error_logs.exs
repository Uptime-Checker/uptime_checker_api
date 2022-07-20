defmodule UptimeChecker.Repo.Migrations.CreateErrorLog do
  use Ecto.Migration

  def change do
    create table(:error_logs) do
      add :text, :string
      add :status_code, :integer
      add :type, :integer

      add :check_id, references(:checks, on_delete: :delete_all)
      add :organization_id, references(:organizations, on_delete: :delete_all)

      timestamps()
    end

    create index(:checks, [:check_id])
    create index(:checks, [:organization_id])
  end
end
