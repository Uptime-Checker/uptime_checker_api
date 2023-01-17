defmodule UptimeChecker.Repo.Migrations.CreateRoles do
  use Ecto.Migration

  def change do
    create table(:roles) do
      add :name, :string, null: false
      add :type, :integer, default: 1

      timestamps()
    end

    create unique_index(:roles, [:type])
  end
end
