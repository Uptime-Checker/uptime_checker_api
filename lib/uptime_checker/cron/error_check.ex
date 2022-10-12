defmodule UptimeChecker.Cron.ErrorCheck do
  use Timex
  require Logger

  alias UptimeChecker.WatchDog
  alias UptimeChecker.Helper.Strings
  alias UptimeChecker.TaskSupervisors
  alias UptimeChecker.Service.MonitorService
  alias UptimeChecker.Schema.WatchDog.{Monitor, MonitorStatusChange}

  def work do
    Logger.info("running error check to pause monitors on too many errors")

    handle_error_check(nil)
    :ok
  end

  def handle_error_check(after_cursor) do
    %{entries: entries, metadata: metadata} = MonitorService.list_all(true, true, after_cursor)

    _ =
      Task.Supervisor.async_stream(
        {:via, PartitionSupervisor, {TaskSupervisors, self()}},
        entries,
        fn entry -> check_monitor(entry) end,
        max_concurrency: 5
      )
      |> Enum.to_list()

    with metadata_after_cursor <- metadata.after do
      unless Strings.blank?(metadata_after_cursor) do
        handle_error_check(metadata_after_cursor)
      end
    end

    :ok
  end

  defp check_monitor(%Monitor{} = monitor) do
    now = Timex.now()

    with %MonitorStatusChange{} = monitor_status <- WatchDog.get_latest_monitor_status_change(monitor.id) do
      if monitor_status.status == :down do
        if Timex.diff(now, monitor_status.changed_at, :hour) > 24 do
          MonitorService.pause_monitor(monitor, false)
        end
      end
    end
  end
end
