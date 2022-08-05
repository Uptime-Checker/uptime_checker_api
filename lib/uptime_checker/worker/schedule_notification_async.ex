defmodule UptimeChecker.Worker.ScheduleNotificationAsync do
  require Logger
  use Oban.Worker, max_attempts: 2, unique: [period: 10]

  alias UptimeChecker.Schema.WatchDog.Alarm

  @impl true
  def perform(%Oban.Job{args: %{"alarm_id" => alarm_id}}) do
    try do
      UptimeChecker.Job.ScheduleNotification.work(alarm_id)
    rescue
      e ->
        Logger.error(e)
    end
  end

  def enqueue(%Alarm{id: id}) do
    %{alarm_id: id}
    |> new()
    |> Oban.insert()
  end
end
