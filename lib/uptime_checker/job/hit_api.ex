defmodule UptimeChecker.Job.HitApi do
  alias UptimeChecker.WatchDog
  alias UptimeChecker.Http.Api

  def work(monitor_region_id) do
    monitor_region = WatchDog.get_monitor_region(monitor_region_id)
    monitor = WatchDog.get_monitor_with_status_codes(monitor_region.monitor_id)

    Api.hit(
      monitor.url,
      monitor.method,
      monitor.headers,
      monitor.body || "",
      monitor.timeout,
      monitor.follow_redirects
    )

    :ok
  end
end
