defmodule UptimeChecker.Repo.Migrations.CreateMonitorIntegrations do
  use Ecto.Migration

  def change do
    create table(:monitor_integrations) do
      add :name, :string
      add :type, :integer
      add :config, :map

      add :organization_id, references(:organizations, on_delete: :delete_all)

      timestamps()
    end

    create index(:monitor_integrations, [:organization_id])
    create unique_index(:monitor_integrations, [:type, :organization_id])
  end
end
