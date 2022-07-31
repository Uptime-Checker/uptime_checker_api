defmodule UptimeChecker.Alarm_S do
  import Ecto.Query, warn: false
  alias UptimeChecker.Repo
  alias UptimeChecker.Schema.WatchDog.Alarm

  def raise_alarm(check, consequtive_failure) when check.monitor.error_threshold >= consequtive_failure do
    alarm = get_ongoing_alarm(check.monitor_id)

    case alarm do
      nil ->
        params =
          %{}
          |> Map.put(:check, check)
          |> Map.put(:monitor, check.monitor)
          |> Map.put(:organization, check.organization)

        with {:ok, %Alarm{} = alarm} <- create_alarm(params) do
          IO.inspect(alarm)
        end
    end
  end

  def get_ongoing_alarm(monitor_id) do
    Alarm |> Repo.get_by(monitor_id: monitor_id, ongoing: true)
  end

  defp create_alarm(attrs) do
    %Alarm{ongoing: true}
    |> Alarm.changeset(attrs)
    |> Repo.insert()
  end
end
