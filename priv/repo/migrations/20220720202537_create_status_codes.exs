defmodule UptimeChecker.Repo.Migrations.CreateStatusCodes do
  use Ecto.Migration

  def change do
    create table(:status_codes) do
      add :name, :string, null: false
      add :code, :integer, null: false
      add :descripition, :string, null: false

      timestamps(type: :timestamptz)
    end
  end
end
