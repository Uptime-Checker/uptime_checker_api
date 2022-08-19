defmodule UptimeChecker.Job.RunChecksOnStarup do
  use Timex
  alias UptimeChecker.WatchDog
  alias UptimeChecker.Helper.String
  alias UptimeChecker.TaskSupervisor

  def work() do
    handle_active_monitors(nil)
    :ok
  end

  defp handle_active_monitors(after_cursor) do
    %{entries: entries, metadata: metadata} = WatchDog.list_monitor_region_for_active_monitors(after_cursor)

    now = NaiveDateTime.utc_now()

    stream =
      Task.Supervisor.async_stream(
        TaskSupervisor,
        entries,
        fn entry -> update_monitor_region(entry, now) end,
        max_concurrency: 5
      )

    Enum.to_list(stream)

    with metadata_after_cursor <- metadata.after do
      unless String.blank?(metadata_after_cursor) do
        handle_active_monitors(metadata_after_cursor)
      end
    end
  end

  defp update_monitor_region(monitor_region, now) do
    later = Timex.shift(now, seconds: monitor_region.monitor.interval + :rand.uniform(60))
    WatchDog.update_monitor_region(monitor_region, %{next_check_at: later})
  end
end
