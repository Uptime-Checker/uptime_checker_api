defmodule UptimeChecker.Worker.SendNotificationAsync do
  require Logger
  use Oban.Worker, max_attempts: 1, unique: [period: 10]

  alias UptimeChecker.Schema.Customer.UserContact

  @impl true
  def perform(%Oban.Job{args: %{"user_contact_id" => user_contact_id}}) do
    try do
      UptimeChecker.Job.SendNotification.work(user_contact_id)
    rescue
      e ->
        Logger.error(e)
    end
  end

  def enqueue(%UserContact{id: id}) do
    %{user_contact_id: id}
    |> new()
    |> Oban.insert()
  end
end
