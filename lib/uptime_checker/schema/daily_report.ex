defmodule UptimeChecker.Schema.DailyReport do
  use Ecto.Schema
  import Ecto.Changeset

  alias UptimeChecker.Schema.WatchDog.Monitor

  schema "daily_reports" do
    field :successful_checks, :integer
    field :error_checks, :integer
    field :downtime, :integer
    field :date, :date

    belongs_to :monitor, Monitor

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(daily_report, attrs) do
    daily_report
    |> cast(attrs, [:successful_checks, :error_checks, :downtime, :date])
    |> unique_constraint([:monitor_id, :date])
    |> put_assoc(:monitor, attrs.monitor)
  end

  def check_update_changeset(daily_report, attrs) do
    daily_report
    |> cast(attrs, [:successful_checks, :error_checks, :downtime, :date])
  end
end
