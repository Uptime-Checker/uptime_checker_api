defmodule UptimeChecker.Job.StartMonitor do
  require Logger

  alias UptimeChecker.WatchDog
  alias UptimeChecker.Job.HitApi
  alias UptimeChecker.Helper.Strings
  alias UptimeChecker.Service.MonitorService

  def work(monitor_id) do
    tracing_id = Strings.random_string(10)
    monitor = MonitorService.get(monitor_id)

    with {u_secs, result} <- HitApi.hit(tracing_id, monitor) do
      duration = round(u_secs / 1000)

      case result do
        {:ok, %HTTPoison.Response{} = _response} ->
          WatchDog.create_monitor_regions(monitor)

        {:error, %HTTPoison.Error{reason: reason}} ->
          Logger.error("#{tracing_id} API Request failed #{monitor.url}, reason #{reason}")
      end
    end

    :ok
  end
end
