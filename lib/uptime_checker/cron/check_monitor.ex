defmodule UptimeChecker.Cron.CheckMonitor do
  require Logger

  alias UptimeChecker.Worker
  alias UptimeChecker.WatchDog
  alias UptimeChecker.Helper.Strings

  def work do
    tracing_id = Strings.random_string(10)
    # Load all the monitors for each region that were supposed to be executed
    # in the last 5 seconds upto next 10 seconds. This cron runs every 10 seconds
    monitor_regions = WatchDog.list_monitor_region(-5, +10)

    Logger.info("#{tracing_id} running check monitor")

    Enum.map(monitor_regions, fn monitor_region ->
      Logger.info("#{tracing_id} enqueue -> #{monitor_region.id}")
      monitor_region |> Worker.HitApiAsync.enqueue()
    end)
  end
end
