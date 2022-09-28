defmodule UptimeChecker.Job.SendNotification do
  alias UptimeChecker.Module.Mailer
  alias UptimeChecker.Mail.MonitorStatus
  alias UptimeChecker.Service.AlarmService
  alias UptimeChecker.{Customer, NotificationService}

  def work(user_contact_id, alarm_id) do
    {:ok, alarm} = AlarmService.get_alarm_by_id(alarm_id)
    {:ok, user_contact} = Customer.get_user_contact_by_id(user_contact_id)
    {:ok, organization} = Customer.get_organization(alarm.organization_id)

    NotificationService.create_notification(
      %{type: alarm_type(alarm.monitor.down)},
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

  defp alarm_type(is_down) when is_down == true, do: :raise_alarm
  defp alarm_type(is_down) when is_down == false, do: :resolve_alarm
end
