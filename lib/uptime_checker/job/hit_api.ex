defmodule UptimeChecker.Job.HitApi do
  def work(monitor_region_id) do
    IO.inspect(monitor_region_id)

    :ok
  end
end
