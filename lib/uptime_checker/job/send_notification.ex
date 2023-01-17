defmodule UptimeChecker.Job.SendNotification do
  require Logger

  alias UptimeChecker.Customer
  alias UptimeChecker.Module.Mailer
  alias UptimeChecker.Mail.MonitorStatus
  alias UptimeChecker.Service.{AlarmService, NotificationService}

  def work(user_contact_id, alarm_id) do
    Logger.info("sending notification for alarm: #{alarm_id} to user contact: #{user_contact_id}")

    {:ok, alarm} = AlarmService.get_alarm_by_id(alarm_id)
    {:ok, user_contact} = Customer.get_user_contact_by_id(user_contact_id)
    {:ok, organization} = Customer.get_organization(alarm.organization_id)

    NotificationService.create_notification(
      %{type: alarm_type(alarm.monitor.status)},
      organization,
      alarm,
      alarm.monitor,
      user_contact
    )

    case user_contact.mode do
      :email ->
        send_email(alarm, user_contact)
    end

    :ok
  end

  defp send_email(alarm, user_contact) do
    MonitorStatus.compose(alarm.monitor, alarm, user_contact)
    |> Mailer.deliver_now!()
  end

  defp alarm_type(status) when status == :failing, do: :raise_alarm
  defp alarm_type(status) when status == :passing, do: :resolve_alarm
end
