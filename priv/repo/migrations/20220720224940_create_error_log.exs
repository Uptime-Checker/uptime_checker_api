defmodule UptimeChecker.Repo.Migrations.CreateErrorLog do
  use Ecto.Migration

  def change do
    create table(:error_log) do
      add :text, :text
      add :type, :integer
      add :screenshot_url, :string

      add :check_id, references(:check, on_delete: :delete_all)
      add :monitor_id, references(:monitor, on_delete: :delete_all)
      add :assertion_id, references(:assertion)

      timestamps()
    end

    create index(:error_log, [:check_id])
    create index(:error_log, [:monitor_id])
    create index(:error_log, [:assertion_id])
  end
end
