defmodule UptimeChecker.Repo.Migrations.CreateMonitorIntegration do
  use Ecto.Migration

  def change do
    create table(:monitor_integration) do
      add :name, :string
      add :type, :integer
      add :config, :map

      add :organization_id, references(:organization, on_delete: :delete_all)

      timestamps()
    end

    create index(:monitor_integration, [:organization_id])
    create unique_index(:monitor_integration, [:type, :organization_id])
  end
end
