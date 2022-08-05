defmodule UptimeChecker.Job.ScheduleNotification do
  alias UptimeChecker.{Alarm_S, WatchDog}
  alias UptimeChecker.Worker.SendNotificationAsync

  def work(alarm_id) do
    alarm = Alarm_S.get_by_id(alarm_id)
    monitor_users_contacts = WatchDog.list_monitor_users_contacts(alarm.monitor.id)

    Enum.each(monitor_users_contacts, fn user_contact ->
      SendNotificationAsync.enqueue(user_contact, alarm)
    end)

    :ok
  end
end
