defmodule UptimeChecker.NotificationService do
  require Logger
  import Ecto.Query, warn: false

  alias UptimeChecker.Repo
  alias UptimeChecker.Schema.WatchDog.Notification

  def create_notification(attrs \\ %{}, organization, alarm, monitor, user_contact) do
    params =
      attrs
      |> Map.put(:alarm, alarm)
      |> Map.put(:monitor, monitor)
      |> Map.put(:organization, organization)
      |> Map.put(:user_contact, user_contact)

    %Notification{}
    |> Notification.changeset(params)
    |> Repo.insert()
  end
end
