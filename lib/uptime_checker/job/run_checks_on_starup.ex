defmodule UptimeChecker.Job.RunChecksOnStarup do
  alias UptimeChecker.WatchDog

  def work() do
    handle_active_monitors()
    :ok
  end

  defp handle_active_monitors() do
    %{entries: entries, metadata: metadata} = WatchDog.list_monitor_region_for_active_monitors()
  end
end
