defmodule UptimeChecker.Cron.CheckMonitor do
  alias UptimeChecker.WatchDog
  alias UptimeChecker.Worker

  def work do
    # Load all the monitors for each region that were supposed to be executed
    # in the last 5 seconds upto next 10 seconds. This cron runs every 10 seconds
    monitor_regions = WatchDog.list_monitor_region(-5, +10)

    Enum.map(monitor_regions, fn monitor_region ->
      monitor_region |> Worker.HitApi.enqueue()
    end)
  end
end
