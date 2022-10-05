defmodule UptimeChecker.Job.RunChecksOnStartup do
  use Timex

  alias UptimeChecker.WatchDog
  alias UptimeChecker.Constant.Env
  alias UptimeChecker.Helper.Strings
  alias UptimeChecker.TaskSupervisors

  def work() do
    handle_active_monitors(nil)
    :ok
  end

  defp handle_active_monitors(after_cursor) do
    %{entries: entries, metadata: metadata} =
      WatchDog.list_monitor_region_for_active_monitors(after_cursor, Env.current_region() |> System.get_env())

    now = Timex.now()

    _ =
      Task.Supervisor.async_stream(
        {:via, PartitionSupervisor, {TaskSupervisors, self()}},
        entries,
        fn entry -> update_monitor_region(entry, now) end,
        max_concurrency: 5
      )
      |> Enum.to_list()

    with metadata_after_cursor <- metadata.after do
      unless Strings.blank?(metadata_after_cursor) do
        handle_active_monitors(metadata_after_cursor)
      end
    end

    :ok
  end

  defp update_monitor_region(monitor_region, now) do
    later = Timex.shift(now, seconds: monitor_region.monitor.interval + :rand.uniform(60))
    WatchDog.update_monitor_region(monitor_region, %{next_check_at: later})
  end
end
