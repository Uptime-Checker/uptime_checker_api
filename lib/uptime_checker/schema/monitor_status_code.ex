defmodule UptimeChecker.Schema.MonitorStatusCode do
  use Ecto.Schema

  alias UptimeChecker.Schema.StatusCode
  alias UptimeChecker.Schema.WatchDog.Monitor

  schema "monitor_status_code_junction" do
    belongs_to(:monitor, Monitor)
    belongs_to(:status_code, StatusCode)

    timestamps()
  end
end
