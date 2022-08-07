defmodule UptimeChecker.Alarm_S do
  require Logger
  import Ecto.Query, warn: false

  alias UptimeChecker.Repo
  alias UptimeChecker.Worker
  alias UptimeChecker.WatchDog
  alias UptimeChecker.Schema.WatchDog.Alarm

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
        cond do
          down_monitor_region_count >= check.monitor.region_threshold ->
            params =
              %{}
              |> Map.put(:check, check)
              |> Map.put(:monitor, check.monitor)
              |> Map.put(:organization, check.organization)

            with {:ok, %Alarm{} = alarm} <- create_alarm(params) do
              Logger.info("#{tracing_id} Alarm created #{alarm.id}, monitor: #{check.monitor.id}")
              Worker.ScheduleNotificationAsync.enqueue(alarm)
            else
              {:error, %Ecto.Changeset{} = changeset} ->
                Logger.error("#{tracing_id}, Failed to create alarm, error: #{inspect(changeset.errors)}")
            end

          true ->
            Logger.debug(
              "#{tracing_id}, Region threshold did not raise alarm, down count: #{down_monitor_region_count}"
            )
        end

      %Alarm{} = alarm ->
        Logger.debug("#{tracing_id}, Alarm already there, #{alarm.id} |> #{alarm.ongoing}")
    end
  end

  def resolve_alarm(tracing_id, check) do
    now = NaiveDateTime.utc_now()
    alarm = get_ongoing_alarm(check.monitor_id)
    up_monitor_region_count = WatchDog.count_monitor_region_by_status(check.monitor_id, false)

    case alarm do
      nil ->
        Logger.debug("#{tracing_id}, No active alarm to resolve, check #{check.id}")

      %Alarm{} = alarm ->
        cond do
          up_monitor_region_count >= check.monitor.region_threshold ->
            alarm
            |> Alarm.resolve_changeset(%{ongoing: false, resolved_at: now, resolved_by_check_id: check.id})
            |> Repo.update()

          true ->
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

  defp create_alarm(attrs) do
    %Alarm{ongoing: true}
    |> Alarm.changeset(attrs)
    |> Repo.insert()
  end
end
