defmodule UptimeChecker.Job.RunChecksOnStarup do
  use Timex
  alias UptimeChecker.WatchDog
  alias UptimeChecker.Helper.String

  def work() do
    handle_active_monitors(nil)
    :ok
  end

  defp handle_active_monitors(after_cursor) do
    %{entries: entries, metadata: metadata} = WatchDog.list_monitor_region_for_active_monitors(after_cursor)

    now = NaiveDateTime.utc_now()

    Enum.each(entries, fn monitor_region ->
      later = Timex.shift(now, seconds: monitor_region.monitor.interval)
      WatchDog.update_monitor_region(monitor_region, %{next_check_at: later})
    end)

    with metadata_after_cursor <- metadata.after do
      unless String.blank?(metadata_after_cursor) do
        handle_active_monitors(metadata_after_cursor)
      end
    end
  end
end
