defmodule UptimeChecker.Cache.MonitorCheck do
  use Timex

  @cache_monitor_check :cache_monitor_check

  def get(monitor_id, scheduled_at) do
    scheduled_at_timestamp = get_scheduled_at_timestamp(scheduled_at)
    key = get_monitor_check_key(monitor_id, scheduled_at_timestamp)
    Cachex.get!(@cache_monitor_check, key)
  end

  def put(monitor_id, scheduled_at) do
    scheduled_at_timestamp = get_scheduled_at_timestamp(scheduled_at)
    key = get_monitor_check_key(monitor_id, scheduled_at_timestamp)
    Cachex.put(@cache_monitor_check, key, monitor_id)
    Cachex.expire(@cache_monitor_check, key, :timer.hours(24))
  end

  defp get_monitor_check_key(monitor_id, scheduled_at_timestamp),
    do: "monitor_check_#{monitor_id}_#{scheduled_at_timestamp}"

  defp get_scheduled_at_timestamp(scheduled_at) do
    scheduled_at |> Timex.to_unix()
  end
end
