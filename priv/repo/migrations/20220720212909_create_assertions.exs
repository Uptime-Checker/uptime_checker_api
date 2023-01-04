defmodule UptimeChecker.Repo.Migrations.CreateMonitorAssertion do
  use Ecto.Migration

  def change do
    create table(:assertion) do
      add :source, :integer, default: 1
      add :property, :string
      add :comparison, :integer, default: 1
      add :value, :string

      add :monitor_id, references(:monitors, on_delete: :delete_all)

      timestamps()
    end

    create index(:assertion, [:monitor_id])
    create unique_index(:assertion, [:source, :value, :monitor_id])
  end
end
