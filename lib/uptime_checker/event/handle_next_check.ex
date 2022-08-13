defmodule UptimeChecker.Event.HandleNextCheck do
  use Timex
  require Logger

  alias UptimeChecker.TaskSupervisor
  alias UptimeChecker.{Alarm_S, WatchDog, DailyReport}

  def act(tracing_id, monitor_region, check, duration, success) do
    # Shift the spent time in hitting api
    now = Timex.shift(NaiveDateTime.utc_now(), milliseconds: -duration)
    monitor = monitor_region.monitor

    daily_report_task =
      Task.Supervisor.async(TaskSupervisor, fn ->
        DailyReport.upsert(monitor, check.organization, success)
      end)

    check_params = %{
      success: success,
      duration: duration
    }

    case WatchDog.handle_next_check(
           monitor,
           monitor_params(success, now),
           monitor_region,
           monitor_region_params(success, now, monitor_region),
           check,
           check_params
         ) do
      {:ok, _monitor, monitor_region, _check} ->
        Logger.info("#{tracing_id} Next check Monitor Region #{monitor_region.id}, at #{monitor_region.next_check_at}")

        # Spin up checking alarm in a separate thread
        Task.Supervisor.start_child(TaskSupervisor, Alarm_S, :handle_alarm, [tracing_id, check, monitor_region.down],
          restart: :transient
        )

        # Await on the daily report task
        daily_report_task |> Task.await()

      {:error, %Ecto.Changeset{} = changeset} ->
        Logger.error("#{tracing_id} Next check schedule failed, error: #{inspect(changeset.errors)}")
    end
  end

  defp monitor_params(success, now) when success == true, do: %{last_checked_at: now}
  defp monitor_params(success, now) when success == false, do: %{last_checked_at: now, last_failed_at: now}

  defp monitor_region_params(success, now, monitor_region) when success == true do
    consequtive_recovery = consequtive_recovery_count(monitor_region.consequtive_recovery, monitor_region)

    consequtive_failure =
      consequtive_failure_count(monitor_region.consequtive_failure, consequtive_recovery, monitor_region)

    %{
      last_checked_at: now,
      next_check_at: Timex.shift(now, seconds: +monitor_region.monitor.interval),
      consequtive_failure: consequtive_failure,
      consequtive_recovery: consequtive_recovery_count(monitor_region.consequtive_recovery, monitor_region),
      down: is_monitor_region_down(consequtive_failure, consequtive_recovery, monitor_region.monitor)
    }
  end

  defp monitor_region_params(success, now, monitor_region) when success == false do
    consequtive_failure = monitor_region.consequtive_failure + 1

    %{
      last_checked_at: now,
      next_check_at: Timex.shift(now, seconds: +monitor_region.monitor.interval),
      consequtive_failure: consequtive_failure,
      consequtive_recovery: 0,
      down: is_monitor_region_down(consequtive_failure, 0, monitor_region.monitor)
    }
  end

  defp consequtive_failure_count(_consequtive_failure, consequtive_recovery, monitor_region)
       when consequtive_recovery >= monitor_region.monitor.resolve_threshold,
       do: 0

  defp consequtive_failure_count(consequtive_failure, _consequtive_recovery, _monitor_region),
    do: consequtive_failure

  defp consequtive_recovery_count(consequtive_recovery, monitor_region)
       when consequtive_recovery >= monitor_region.monitor.resolve_threshold,
       do: 0

  defp consequtive_recovery_count(_consequtive_recovery, monitor_region),
    do: monitor_region.consequtive_recovery + 1

  defp is_monitor_region_down(consequtive_failure, _consequtive_recovery, monitor)
       when consequtive_failure >= monitor.error_threshold,
       do: true

  defp is_monitor_region_down(_consequtive_failure, consequtive_recovery, monitor)
       when consequtive_recovery >= monitor.resolve_threshold,
       do: false

  defp is_monitor_region_down(consequtive_failure, _consequtive_recovery, monitor)
       when consequtive_failure < monitor.error_threshold,
       do: false
end
