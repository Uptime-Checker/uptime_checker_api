defmodule UptimeChecker.Alarm_S do
  require Logger
  import Ecto.Query, warn: false

  alias UptimeChecker.Repo
  alias UptimeChecker.Worker
  alias UptimeChecker.Schema.WatchDog.Alarm

  def raise_alarm(tracing_id, check, consequtive_failure) when consequtive_failure >= check.monitor.error_threshold do
    alarm = get_ongoing_alarm(check.monitor_id)

    case alarm do
      nil ->
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

      %Alarm{} = alarm ->
        Logger.debug("#{tracing_id}, Alarm already there, #{alarm.id} |> #{alarm.ongoing}")
    end
  end

  def raise_alarm(_tracing_id, _check, _consequtive_failure), do: :ok

  def resolve_alarm(tracing_id, check, consequtive_recovery)
      when consequtive_recovery >= check.monitor.resolve_threshold do
    now = NaiveDateTime.utc_now()
    alarm = get_ongoing_alarm(check.monitor_id)

    case alarm do
      nil ->
        Logger.error("#{tracing_id}, No active alarm found, check #{check.id}")

      %Alarm{} = alarm ->
        alarm
        |> Alarm.resolve_changeset(%{ongoing: false, resolved_at: now, resolved_by: check})
        |> Repo.update()
    end
  end

  def resolve_alarm(_tracing_id, _check, _consequtive_failure), do: :ok

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
