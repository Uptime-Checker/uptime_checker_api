defmodule UptimeChecker.Worker.ScheduleNotificationAsync do
  require Logger
  use Oban.Worker, queue: :notification, max_attempts: 2, unique: [period: 5]

  alias UptimeChecker.Schema.WatchDog.Alarm

  @impl true
  def perform(%Oban.Job{args: %{"alarm_id" => alarm_id}}) do
    try do
      UptimeChecker.Job.ScheduleNotification.work(alarm_id)
    rescue
      e ->
        Logger.error(e)
        Sentry.capture_exception(e, stacktrace: __STACKTRACE__, extra: %{module: __MODULE__})
    end
  end

  def enqueue(%Alarm{id: id}) do
    %{alarm_id: id}
    |> new()
    |> Oban.insert()
  end
end
