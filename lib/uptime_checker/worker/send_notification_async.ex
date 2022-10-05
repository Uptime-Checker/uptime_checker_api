defmodule UptimeChecker.Worker.SendNotificationAsync do
  require Logger
  use Oban.Worker, max_attempts: 1, queue: :notification

  alias UptimeChecker.Schema.WatchDog.Alarm
  alias UptimeChecker.Schema.Customer.UserContact

  @impl true
  def perform(%Oban.Job{args: %{"user_contact_id" => user_contact_id, "alarm_id" => alarm_id}}) do
    try do
      UptimeChecker.Job.SendNotification.work(user_contact_id, alarm_id)
    rescue
      e ->
        Logger.error(e)
        Sentry.capture_exception(e, stacktrace: __STACKTRACE__, extra: %{module: __MODULE__})
    end
  end

  def enqueue(%UserContact{id: user_contact_id}, %Alarm{id: alarm_id}) do
    %{user_contact_id: user_contact_id, alarm_id: alarm_id}
    |> new(queue: :notification)
    |> Oban.insert()
  end
end
