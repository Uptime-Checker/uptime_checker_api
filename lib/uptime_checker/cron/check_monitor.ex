defmodule UptimeChecker.Cron.CheckMonitor do
  require Logger

  alias UptimeChecker.Cache
  alias UptimeChecker.Worker
  alias UptimeChecker.WatchDog
  alias UptimeChecker.Helper.Strings
  alias UptimeChecker.TaskSupervisors

  def work do
    tracing_id = Strings.random_string(10)
    # Load all the monitors for each region that were supposed to be executed
    # in the last 5 seconds upto next 10 seconds. This cron runs every 10 seconds
    monitor_regions = WatchDog.list_monitor_region(-5, +10)

    Logger.info("#{tracing_id} running check monitor cron, count: #{Enum.count(monitor_regions)}")

    _ =
      Task.Supervisor.async_stream(
        {:via, PartitionSupervisor, {TaskSupervisors, self()}},
        monitor_regions,
        fn monitor_region ->
          cached_monitor_region_check = Cache.MonitorRegionCheck.get(monitor_region.id, monitor_region.next_check_at)

          if is_nil(cached_monitor_region_check) do
            Logger.info("#{tracing_id} enqueue -> #{monitor_region.id}")
            monitor_region |> Worker.HitApiAsync.enqueue()
            Cache.MonitorRegionCheck.put(monitor_region.id, monitor_region.next_check_at)
          end
        end,
        max_concurrency: 5
      )
      |> Enum.to_list()
  end
end
