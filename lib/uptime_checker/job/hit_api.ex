defmodule UptimeChecker.Job.HitApi do
  alias UptimeChecker.WatchDog

  def work(monitor_region_id) do
    monitor_region = WatchDog.get_monitor_region(monitor_region_id)

    IO.inspect(monitor_region)
    :ok
  end
end
