defmodule UptimeChecker.Repo.Migrations.CreateErrorLogs do
  use Ecto.Migration

  def change do
    create table(:error_logs) do
      add :text, :text
      add :status_code, :integer
      add :type, :integer
      add :screenshot_url, :string

      add :check_id, references(:checks, on_delete: :delete_all)
      add :monitor_id, references(:monitors, on_delete: :delete_all)
      add :assertion_id, references(:assertions)

      timestamps()
    end

    create index(:error_logs, [:check_id])
    create index(:error_logs, [:monitor_id])
    create index(:error_logs, [:assertion_id])
  end
end
