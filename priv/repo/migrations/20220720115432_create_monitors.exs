defmodule UptimeChecker.Repo.Migrations.CreateMonitors do
  use Ecto.Migration

  def change do
    create table(:monitors) do
      add :name, :string
      add :url, :string
      add :method, :integer
      add :status_codes, {:array, :integer}
      add :interval, :integer
      add :timeout, :integer
      add :last_checked_at, :utc_datetime
      add :last_failed_at, :utc_datetime
      add :resolve_threshold, :integer
      add :body, :string
      add :contains, :string
      add :state, :integer

      timestamps()
    end
  end
end
