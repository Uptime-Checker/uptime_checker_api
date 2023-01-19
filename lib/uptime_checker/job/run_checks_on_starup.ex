defmodule UptimeChecker.Job.RunChecksOnStartup do
  use Timex
  require Logger

  alias UptimeChecker.WatchDog
  alias UptimeChecker.Helper.Strings
  alias UptimeChecker.TaskSupervisors
  alias UptimeChecker.Schema.WatchDog.Monitor

  def work() do
    Logger.info("running active monitor check on startup")

    handle_active_monitors(nil)
    :ok
  end

  defp handle_active_monitors(after_cursor) do
    %{entries: entries, metadata: metadata} = WatchDog.list_active_monitors(after_cursor)

    now = Timex.now()

    _ =
      Task.Supervisor.async_stream(
        {:via, PartitionSupervisor, {TaskSupervisors, self()}},
        entries,
        fn entry -> update_monitor(entry, now) end,
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

  defp update_monitor(%Monitor{} = monitor, now) do
    later = Timex.shift(now, seconds: monitor.interval + :rand.uniform(60))
    WatchDog.update_monitor(monitor, %{next_check_at: later})
  end
end
