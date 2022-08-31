defmodule UptimeChecker.Schema.MonitorStatusCode do
  use Ecto.Schema
  import Ecto.Changeset

  alias UptimeChecker.Schema.StatusCode
  alias UptimeChecker.Schema.WatchDog.Monitor

  schema "monitor_status_code_junction" do
    belongs_to :monitor, Monitor
    belongs_to :status_code, StatusCode

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(monitor_status_code, attrs) do
    monitor_status_code
    |> cast(attrs, [:monitor_id, :status_code_id])
    |> put_assoc(:monitor, attrs.monitor)
    |> put_assoc(:status_code, attrs.status_code)
    |> unique_constraint([:status_code_id, :monitor_id])
  end
end
