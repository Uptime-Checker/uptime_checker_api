defmodule UptimeChecker.Repo.Migrations.CreateAssertion do
  use Ecto.Migration

  def change do
    create table(:assertions) do
      add :source, :integer, default: 1
      add :property, :string
      add :comparison, :integer, default: 1
      add :value, :string

      add :monitor_id, references(:monitors, on_delete: :delete_all)

      timestamps()
    end

    create index(:assertions, [:monitor_id])
    create unique_index(:assertions, [:source, :value, :monitor_id])
  end
end
