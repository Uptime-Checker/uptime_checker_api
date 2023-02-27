defmodule UptimeChecker.Repo.Migrations.CreateRole do
  use Ecto.Migration

  def change do
    create table(:role) do
      add :name, :string, null: false
      add :type, :integer, default: 1

      timestamps()
    end

    create unique_index(:role, [:type])
  end
end
