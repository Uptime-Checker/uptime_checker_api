defmodule UptimeChecker.Job.HitApi do
  alias UptimeChecker.WatchDog

  def work(monitor_region_id) do
    monitor_region = WatchDog.get_monitor_region(monitor_region_id)
    monitor = WatchDog.get_monitor_with_status_codes(monitor_region.monitor_id)

    IO.inspect(monitor)
    :ok
  end
end
