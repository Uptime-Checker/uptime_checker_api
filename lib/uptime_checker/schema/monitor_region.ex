defmodule UptimeChecker.Schema.MonitorRegion do
  use Ecto.Schema

  alias UptimeChecker.Schema.Region
  alias UptimeChecker.Schema.WatchDog.Monitor

  schema "monitor_region_junction" do
    belongs_to(:monitor, Monitor)
    belongs_to(:region, Region)

    timestamps()
  end
end
