defmodule UptimeChecker.Repo.Migrations.CreateFeatures do
  use Ecto.Migration

  def change do
    create table(:features) do
      add :name, :string, null: false
      add :type, :integer, default: 1

      timestamps()
    end

    create unique_index(:features, [:name, :type])
  end
end
