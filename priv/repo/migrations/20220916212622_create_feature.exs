defmodule UptimeChecker.Repo.Migrations.CreateFeature do
  use Ecto.Migration

  def change do
    create table(:feature) do
      add :name, :string, null: false
      add :type, :integer, default: 1

      timestamps()
    end

    create unique_index(:feature, [:name, :type])
  end
end
