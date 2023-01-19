defmodule UptimeChecker.Service.AlarmService do
  use Timex
  require Logger
  import Ecto.Query, warn: false

  alias UptimeChecker.Repo
  alias UptimeChecker.Worker
  alias UptimeChecker.Helper.Times
  alias UptimeChecker.Error.RepoError
  alias UptimeChecker.{WatchDog, DailyReport}
  alias UptimeChecker.Schema.Customer.Organization
  alias UptimeChecker.Schema.WatchDog.{Alarm, Check, Monitor, MonitorStatusChange}

  # When a monitor region goes down, this is hit
  def handle_alarm(tracing_id, %Check{} = check, is_down) do
    cond do
      is_down == true ->
        raise_alarm(tracing_id, check)

      is_down == false ->
        resolve_alarm(tracing_id, check)
    end
  end

  defp raise_alarm(tracing_id, %Check{} = check) do
    monitor = check.monitor
    alarm = get_ongoing_alarm(monitor.id)
    down_monitor_region_count = WatchDog.count_monitor_region_by_status(monitor.id, true)

    case alarm do
      {:error, %ErrorMessage{code: :not_found} = _e} ->
        if down_monitor_region_count >= monitor.region_threshold &&
             is_monitor_potentially_down(monitor.consecutive_failure, monitor.consecutive_recovery, monitor) do
          params =
            %{}
            |> Map.put(:check, check)
            |> Map.put(:monitor, monitor)
            |> Map.put(:organization, check.organization)

          case create_alarm(monitor, params) do
            {:ok, %Alarm{} = alarm} ->
              Logger.info("#{tracing_id} 1 Alarm created #{alarm.id}, monitor: #{monitor.id}")
              Worker.ScheduleNotificationAsync.enqueue(alarm)

            {:error, %Ecto.Changeset{} = changeset} ->
              Logger.error("#{tracing_id} 2 Failed to create alarm, error: #{inspect(changeset.errors)}")
          end
        else
          if monitor.status != :degraded do
            case handle_degraded(monitor, true) do
              {:ok, %Monitor{} = monitor} ->
                Logger.info(
                  "#{tracing_id} 3 Region threshold did not raise alarm, but degrading monitor: #{monitor.id}"
                )

              {:error, %Ecto.Changeset{} = changeset} ->
                Logger.error("#{tracing_id} 4 Failed to degrade monitor, error: #{inspect(changeset.errors)}")
            end
          end
        end

      {:ok, %Alarm{} = alarm} ->
        Logger.info("#{tracing_id} 5 Alarm already there, #{alarm.id} |> #{alarm.ongoing}")
    end
  end

  defp resolve_alarm(tracing_id, %Check{} = check) do
    now = Timex.now()

    monitor = check.monitor
    alarm = get_ongoing_alarm(monitor.id)
    up_monitor_region_count = WatchDog.count_monitor_region_by_status(monitor.id, false)

    case alarm do
      {:error, %ErrorMessage{code: :not_found} = _e} ->
        Logger.debug("#{tracing_id}, 1 No active alarm to resolve, check #{check.id}")
        total_monitor_region_count = WatchDog.count_monitor_region(monitor.id)

        if total_monitor_region_count == up_monitor_region_count && monitor.status != :passing do
          # resolve degraded
          case handle_degraded(monitor, false) do
            {:ok, %Monitor{} = monitor} ->
              Logger.info("#{tracing_id} 2 Degraded monitor resolved: #{monitor.id}")

            {:error, %Ecto.Changeset{} = changeset} ->
              Logger.error("#{tracing_id} 3 Failed to resolve degrade monitor, error: #{inspect(changeset.errors)}")
          end
        end

      {:ok, %Alarm{} = alarm} ->
        if up_monitor_region_count >= monitor.region_threshold &&
             !is_monitor_potentially_down(monitor.consecutive_failure, monitor.consecutive_recovery, monitor) do
          case clear_alarm(monitor, alarm, now, check) do
            {:ok, updated_alarm} ->
              Logger.info("#{tracing_id} 4 Alarm resolved #{alarm.id}, monitor: #{monitor.id}")
              Worker.ScheduleNotificationAsync.enqueue(updated_alarm)
              update_duration_in_daily_report(check.organization, monitor, updated_alarm)

            {:error, %Ecto.Changeset{} = changeset} ->
              Logger.error("#{tracing_id} 5 Failed to resolve alarm, error: #{inspect(changeset.errors)}")
          end
        else
          Logger.debug("#{tracing_id} 6 Region threshold did not resolve alarm, up count: #{up_monitor_region_count}")
        end
    end
  end

  def get_ongoing_alarm(monitor_id) do
    Alarm
    |> Repo.get_by(monitor_id: monitor_id, ongoing: true)
    |> case do
      nil -> {:error, RepoError.alarm_not_found() |> ErrorMessage.not_found(%{monitor_id: monitor_id})}
      alarm -> {:ok, alarm}
    end
  end

  def get_alarm_by_id(id) do
    query =
      from alarm in Alarm,
        left_join: m in assoc(alarm, :monitor),
        left_join: t in assoc(alarm, :triggered_by),
        where: alarm.id == ^id,
        preload: [monitor: m, triggered_by: t]

    Repo.one(query)
    |> case do
      nil -> {:error, RepoError.alarm_not_found() |> ErrorMessage.not_found(%{id: id})}
      alarm -> {:ok, alarm}
    end
  end

  # Ceeates new alarm, updates monitor's status, inserts new entry in monitor status change log
  defp create_alarm(%Monitor{} = monitor, attrs) do
    now = Timex.now()

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:alarm, Alarm.changeset(%Alarm{ongoing: true}, attrs))
    |> Ecto.Multi.run(:monitor, fn _repo, %{alarm: _alarm} ->
      WatchDog.update_monitor_status(monitor, %{status: :failing})
    end)
    |> Ecto.Multi.insert(
      :monitor_status_change,
      MonitorStatusChange.changeset(%MonitorStatusChange{}, %{status: :failing, changed_at: now, monitor: monitor})
    )
    |> Repo.transaction()
    |> case do
      {:ok, %{alarm: alarm, monitor: _monitor, monitor_status_change: _monitor_status_change}} ->
        {:ok, alarm}

      {:error, _name, changeset, _changes_so_far} ->
        {:error, changeset}
    end
  end

  defp handle_degraded(%Monitor{} = monitor, is_degraded) do
    now = Timex.now()

    status =
      if is_degraded do
        :degraded
      else
        :passing
      end

    Ecto.Multi.new()
    |> Ecto.Multi.update(:monitor, WatchDog.update_monitor_status(monitor, %{status: status}))
    |> Ecto.Multi.insert(
      :monitor_status_change,
      MonitorStatusChange.changeset(%MonitorStatusChange{}, %{status: status, changed_at: now, monitor: monitor})
    )
    |> Repo.transaction()
    |> case do
      {:ok, %{monitor: monitor, monitor_status_change: _monitor_status_change}} ->
        {:ok, monitor}

      {:error, _name, changeset, _changes_so_far} ->
        {:error, changeset}
    end
  end

  # Resolves alarm, updates monitor's status, inserts new entry in monitor status change log
  defp clear_alarm(%Monitor{} = monitor, %Alarm{} = alarm, now, %Check{} = check) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(
      :alarm,
      Alarm.resolve_changeset(alarm, %{ongoing: false, resolved_at: now, resolved_by_check_id: check.id})
    )
    |> Ecto.Multi.run(:monitor, fn _repo, %{alarm: _alarm} ->
      WatchDog.update_monitor_status(monitor, %{status: :passing})
    end)
    |> Ecto.Multi.insert(
      :monitor_status_change,
      MonitorStatusChange.changeset(%MonitorStatusChange{}, %{status: :passing, changed_at: now, monitor: monitor})
    )
    |> Repo.transaction()
    |> case do
      {:ok, %{alarm: alarm, monitor: _monitor, monitor_status_change: _monitor_status_change}} ->
        {:ok, alarm}

      {:error, _name, changeset, _changes_so_far} ->
        {:error, changeset}
    end
  end

  defp update_duration_in_daily_report(%Organization{} = organization, %Monitor{} = monitor, %Alarm{} = alarm) do
    DailyReport.update_duration(
      monitor,
      organization,
      Times.get_duration_in_seconds(alarm.resolved_at, alarm.inserted_at)
    )
  end

  defp is_monitor_potentially_down(consecutive_failure, _consecutive_recovery, monitor)
       when consecutive_failure >= monitor.error_threshold,
       do: true

  defp is_monitor_potentially_down(_consecutive_failure, consecutive_recovery, monitor)
       when consecutive_recovery >= monitor.resolve_threshold,
       do: false

  defp is_monitor_potentially_down(consecutive_failure, _consecutive_recovery, monitor)
       when consecutive_failure < monitor.error_threshold,
       do: false
end
