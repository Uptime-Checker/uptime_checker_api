defmodule UptimeChecker.Job.SendNotification do
  alias UptimeChecker.{Customer, Alarm_S}

  def work(user_contact_id, alarm_id) do
    alarm = Alarm_S.get_by_id(alarm_id)
    user_contact = Customer.get_user_contact_by_id(user_contact_id)

    IO.inspect(user_contact)
    IO.inspect(alarm)

    :ok
  end
end
