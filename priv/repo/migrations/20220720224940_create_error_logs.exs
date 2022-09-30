defmodule UptimeChecker.Repo.Migrations.CreateErrorLog do
  use Ecto.Migration

  def change do
    create table(:error_logs) do
      add :text, :text
      add :status_code, :integer
      add :type, :integer
      add :screenshot_url, :string

      add :check_id, references(:checks, on_delete: :delete_all)
      add :organization_id, references(:organizations, on_delete: :delete_all)

      timestamps()
    end

    create index(:error_logs, [:check_id])
    create index(:error_logs, [:organization_id])
  end
end
