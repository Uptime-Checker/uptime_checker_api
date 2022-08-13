defmodule UptimeChecker.Job.SendNotification do
  alias UptimeChecker.Module.Mailer
  alias UptimeChecker.Mail.MonitorStatus
  alias UptimeChecker.{Customer, Alarm_S}

  def work(user_contact_id, alarm_id) do
    alarm = Alarm_S.get_by_id(alarm_id)
    user_contact = Customer.get_user_contact_by_id(user_contact_id)

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
end
