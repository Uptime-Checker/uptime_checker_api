defmodule UptimeChecker.Cache.MonitorRegionCheck do
  use Timex

  @cache_monitor_region_check :cache_monitor_region_check

  def get(monitor_region_id, scheduled_at) do
    scheduled_at_timestamp = get_scheduled_at_timestamp(scheduled_at)
    key = get_monitor_region_check_key(monitor_region_id, scheduled_at_timestamp)
    Cachex.get!(@cache_monitor_region_check, key)
  end

  def put(monitor_region_id, scheduled_at) do
    scheduled_at_timestamp = get_scheduled_at_timestamp(scheduled_at)
    key = get_monitor_region_check_key(monitor_region_id, scheduled_at_timestamp)
    Cachex.put(@cache_monitor_region_check, key, monitor_region_id)
    Cachex.expire(@cache_monitor_region_check, key, :timer.seconds(60))
  end

  defp get_monitor_region_check_key(monitor_region_id, scheduled_at_timestamp),
    do: "monitor_region_check_#{monitor_region_id}_#{scheduled_at_timestamp}"

  defp get_scheduled_at_timestamp(scheduled_at) do
    scheduled_at |> Timex.to_unix()
  end
end
