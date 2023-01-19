defmodule UptimeChecker.Event.HandleNextCheck do
  use Timex
  require Logger

  alias UptimeChecker.TaskSupervisors
  alias UptimeChecker.Service.AlarmService
  alias UptimeChecker.{WatchDog, DailyReport, Payment}
  alias UptimeChecker.Schema.WatchDog.{Check, MonitorRegion, Monitor}

  def act(tracing_id, %MonitorRegion{} = monitor_region, %Check{} = check, duration, success) do
    # Shift the spent time in hitting api
    now = Timex.now() |> Timex.shift(milliseconds: -duration)
    monitor = monitor_region.monitor

    Task.Supervisor.start_child(
      {:via, PartitionSupervisor, {TaskSupervisors, self()}},
      fn ->
        DailyReport.upsert(monitor, check.organization, success)
      end,
      restart: :transient
    )

    if can_schedule(tracing_id, monitor, check) do
      case WatchDog.handle_next_check(
             monitor,
             monitor_params(monitor, success, now),
             monitor_region,
             %{last_checked_at: now, down: !success},
             check,
             %{success: success, duration: duration}
           ) do
        {:ok, _monitor, monitor_region, _check} ->
          Logger.info(
            "#{tracing_id} Next check Monitor Region #{monitor_region.id}, at #{monitor_region.next_check_at}"
          )

          # Check for checking alarm
          AlarmService.handle_alarm(tracing_id, check, monitor_region.down)

        {:error, %Ecto.Changeset{} = changeset} ->
          Logger.error("#{tracing_id} Next check schedule failed, error: #{inspect(changeset.errors)}")
      end
    end
  end

  defp can_schedule(tracing_id, %Monitor{} = monitor, %Check{} = check) do
    case Payment.get_active_subsription(check.organization_id) do
      {:ok, _subscription} ->
        monitor.on

      {:error, %ErrorMessage{code: :not_found} = e} ->
        Logger.warn("#{tracing_id} Active subscription not found to start new check, error: #{inspect(e)}")
        false
    end
  end

  defp monitor_params(monitor, success, now) when success == true do
    consequtive_recovery = consequtive_recovery_count(monitor.consequtive_recovery, monitor)
    consequtive_failure = consequtive_failure_count(monitor.consequtive_failure, consequtive_recovery, monitor)

    %{
      last_checked_at: now,
      next_check_at: Timex.shift(now, seconds: +monitor.interval),
      consequtive_failure: consequtive_failure,
      consequtive_recovery: consequtive_recovery
    }
  end

  defp monitor_params(monitor, success, now) when success == false do
    consequtive_failure = monitor.consequtive_failure + 1

    %{
      last_checked_at: now,
      next_check_at: Timex.shift(now, seconds: +monitor.interval),
      consequtive_failure: consequtive_failure,
      consequtive_recovery: 0
    }
  end

  defp consequtive_failure_count(_consequtive_failure, consequtive_recovery, monitor)
       when consequtive_recovery >= monitor.resolve_threshold,
       do: 0

  defp consequtive_failure_count(consequtive_failure, _consequtive_recovery, _monitor),
    do: consequtive_failure

  defp consequtive_recovery_count(consequtive_recovery, monitor)
       when consequtive_recovery >= monitor.resolve_threshold,
       do: 0

  defp consequtive_recovery_count(_consequtive_recovery, monitor),
    do: monitor.consequtive_recovery + 1
end
