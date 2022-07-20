defmodule UptimeChecker.Repo.Migrations.CreateStatusCodesTable do
  use Ecto.Migration

  def change do
    create table(:status_codes) do
      add :name, :string, null: false
      add :code, :integer, null: false
      add :descripition, :string, null: false

      timestamps()
    end
  end
end
