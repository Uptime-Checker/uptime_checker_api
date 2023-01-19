defmodule UptimeChecker.Cron.CheckMonitor do
  require Logger

  alias UptimeChecker.Cache
  alias UptimeChecker.Worker
  alias UptimeChecker.WatchDog
  alias UptimeChecker.Constant.Env
  alias UptimeChecker.Helper.Strings
  alias UptimeChecker.TaskSupervisors

  def work do
    tracing_id = Strings.random_string(10)
    # Load all the monitors for each region that were supposed to be executed (is on)
    # in the last 5 seconds upto next 10 seconds. This cron runs every 10 seconds
    monitors = WatchDog.list_monitors_to_run(-5, +10)
    Logger.info("#{tracing_id} running check monitor cron, count: #{Enum.count(monitors)}")

    _ =
      Task.Supervisor.async_stream(
        {:via, PartitionSupervisor, {TaskSupervisors, self()}},
        monitors,
        fn monitor ->
          cached_monitor_check = Cache.MonitorCheck.get(monitor.id, monitor.next_check_at)

          if is_nil(cached_monitor_check) do
            monitor_region = WatchDog.list_oldest_checked_monitor_region(monitor.id)

            if monitor_region.region.key == Env.current_region() |> System.get_env() do
              Logger.info("#{tracing_id} enqueue -> #{monitor.id} in region #{monitor_region.region.key}}")
              Worker.HitApiAsync.enqueue(monitor_region.id, monitor.next_check_at)
              Cache.MonitorCheck.put(monitor.id, monitor.next_check_at)
            end
          end
        end,
        max_concurrency: 5
      )
      |> Enum.to_list()
  end
end
