defmodule UptimeChecker.Job.StartMonitor do
  require Logger

  alias UptimeChecker.WatchDog
  alias UptimeChecker.Job.HitApi
  alias UptimeChecker.Helper.Strings
  alias UptimeChecker.Schema.WatchDog.Check
  alias UptimeChecker.Service.{MonitorService, RegionService}
  alias UptimeChecker.Event.{HandleErrorLog, HandleApiResponse}

  def work(monitor_id) do
    tracing_id = Strings.random_string(10)

    Logger.info("#{tracing_id} starting monitor async, monitor: #{monitor_id}")

    with {:ok, monitor} <- MonitorService.get_with_all_assoc(monitor_id),
         {:ok, region} <- RegionService.get_current_region(),
         {:ok, check} <- WatchDog.create_check(%{}, monitor, region, monitor.organization) do
      with {u_secs, result} <- HitApi.hit(tracing_id, monitor) do
        duration = round(u_secs / 1000)

        case result do
          {:ok, %HTTPoison.Response{} = response} ->
            Logger.info(
              "#{tracing_id} RESPONSE #{check.monitor.url} CODE ==> #{response.status_code} DURATION ==> #{duration}"
            )

            handle_response(tracing_id, response, check, duration)

          {:error, %HTTPoison.Error{reason: reason}} ->
            Logger.error("#{tracing_id} API Request failed #{monitor.url}, reason #{reason}")
            handle_poison_error(tracing_id, reason, check, duration)
        end
      end
    end

    :ok
  end

  defp handle_response(tracing_id, %HTTPoison.Response{} = response, %Check{} = check, duration) do
    case HandleApiResponse.handle(response, check.monitor) do
      {:ok, _success} ->
        handle_successful_response(check, duration)

      {:error, code} ->
        handle_failure_from_response(tracing_id, response, check, duration, code)
    end
  end

  defp handle_successful_response(%Check{} = check, duration) do
    WatchDog.create_monitor_regions(check.monitor)
    WatchDog.update_check(check, %{success: true, duration: duration})
    WatchDog.create_monitor_status_change(:up, check.monitor)
  end

  defp handle_poison_error(tracing_id, reason, %Check{} = check, duration) do
    HandleErrorLog.finalize(tracing_id, reason, check)
    update_check_and_pause_monitor(check, duration)
  end

  defp handle_failure_from_response(tracing_id, %HTTPoison.Response{} = response, %Check{} = check, duration, code) do
    HandleErrorLog.create(tracing_id, response.body, response.status_code, check, code)
    update_check_and_pause_monitor(check, duration)
  end

  defp update_check_and_pause_monitor(%Check{} = check, duration) do
    WatchDog.update_check(check, %{success: false, duration: duration})
    MonitorService.pause_monitor(check.monitor, false)
  end
end
