defmodule UptimeChecker.Job.ScheduleNotification do
  require Logger

  alias UptimeChecker.WatchDog
  alias UptimeChecker.Service.AlarmService
  alias UptimeChecker.Worker.SendNotificationAsync

  def work(alarm_id) do
    Logger.info("scheduling notification for alarm: #{alarm_id}")

    {:ok, alarm} = AlarmService.get_alarm_by_id(alarm_id)
    monitor_users_contacts = WatchDog.list_monitor_users_contacts(alarm.monitor.id)

    Enum.each(monitor_users_contacts, fn user_contact ->
      SendNotificationAsync.enqueue(user_contact, alarm)
    end)

    :ok
  end
end
