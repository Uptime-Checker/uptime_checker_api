defmodule UptimeChecker.AlarmService do
  require Logger
  import Ecto.Query, warn: false

  alias UptimeChecker.Repo
  alias UptimeChecker.Worker
  alias UptimeChecker.Helper.Times
  alias UptimeChecker.TaskSupervisor
  alias UptimeChecker.Schema.WatchDog.Alarm
  alias UptimeChecker.{WatchDog, DailyReport}

  def handle_alarm(tracing_id, check, is_down) do
    cond do
      is_down == true ->
        raise_alarm(tracing_id, check)

      is_down == false ->
        resolve_alarm(tracing_id, check)
    end
  end

  defp raise_alarm(tracing_id, check) do
    alarm = get_ongoing_alarm(check.monitor_id)
    down_monitor_region_count = WatchDog.count_monitor_region_by_status(check.monitor_id, true)

    case alarm do
      nil ->
        if down_monitor_region_count >= check.monitor.region_threshold do
          params =
            %{}
            |> Map.put(:check, check)
            |> Map.put(:monitor, check.monitor)
            |> Map.put(:organization, check.organization)

          case create_alarm(check.monitor, params) do
            {:ok, %Alarm{} = alarm} ->
              Logger.info("#{tracing_id} Alarm created #{alarm.id}, monitor: #{check.monitor.id}")
              Worker.ScheduleNotificationAsync.enqueue(alarm)

            {:error, %Ecto.Changeset{} = changeset} ->
              Logger.error("#{tracing_id}, Failed to create alarm, error: #{inspect(changeset.errors)}")
          end
        else
          Logger.debug("#{tracing_id}, Region threshold did not raise alarm, down count: #{down_monitor_region_count}")
        end

      %Alarm{} = alarm ->
        Logger.debug("#{tracing_id}, Alarm already there, #{alarm.id} |> #{alarm.ongoing}")
    end
  end

  defp resolve_alarm(tracing_id, check) do
    now = NaiveDateTime.utc_now()
    alarm = get_ongoing_alarm(check.monitor_id)
    up_monitor_region_count = WatchDog.count_monitor_region_by_status(check.monitor_id, false)

    case alarm do
      nil ->
        Logger.debug("#{tracing_id}, No active alarm to resolve, check #{check.id}")

      %Alarm{} = alarm ->
        if up_monitor_region_count >= check.monitor.region_threshold do
          with {:ok, updated_alarm} <- resolve_alarm(check.monitor, alarm, now, check) do
            update_duration_in_daily_report_async(check.organization, check.monitor, updated_alarm)
          end

          Worker.ScheduleNotificationAsync.enqueue(alarm)
        else
          Logger.debug("#{tracing_id}, Region threshold did not raise alarm, up count: #{up_monitor_region_count}")
        end
    end
  end

  def get_ongoing_alarm(monitor_id) do
    Alarm |> Repo.get_by(monitor_id: monitor_id, ongoing: true)
  end

  def get_by_id(id) do
    Alarm
    |> Repo.get(id)
    |> Repo.preload([:monitor])
    |> Repo.preload([:triggered_by])
  end

  defp create_alarm(monitor, attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(:alarm, Alarm.changeset(%Alarm{ongoing: true}, attrs))
    |> Ecto.Multi.run(:monitor, fn _repo, %{alarm: _alarm} ->
      WatchDog.update_monitor_status(monitor, %{down: true})
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{alarm: alarm, monitor: _monitor}} ->
        {:ok, alarm}

      {:error, _name, changeset, _changes_so_far} ->
        {:error, changeset}
    end
  end

  defp resolve_alarm(monitor, alarm, now, check) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(
      :alarm,
      Alarm.resolve_changeset(alarm, %{ongoing: false, resolved_at: now, resolved_by_check_id: check.id})
    )
    |> Ecto.Multi.run(:monitor, fn _repo, %{alarm: _alarm} ->
      WatchDog.update_monitor_status(monitor, %{down: false})
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{alarm: alarm, monitor: _monitor}} ->
        {:ok, alarm}

      {:error, _name, changeset, _changes_so_far} ->
        {:error, changeset}
    end
  end

  defp update_duration_in_daily_report_async(organization, monitor, alarm) do
    Task.Supervisor.start_child(
      TaskSupervisor,
      DailyReport,
      :update_duration,
      [monitor, organization, Times.get_duration_in_seconds(alarm.resolved_at, alarm.inserted_at)],
      restart: :transient
    )
  end
end
