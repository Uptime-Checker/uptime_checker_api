defmodule UptimeChecker.Repo.Migrations.CreateClaims do
  use Ecto.Migration

  def change do
    create table(:claims) do
      add :name, :string, null: false

      timestamps()
    end

    create unique_index(:claims, [:name])
  end
end
