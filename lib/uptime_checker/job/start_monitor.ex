defmodule UptimeChecker.Job.StartMonitor do
  require Logger

  alias UptimeChecker.Job.HitApi
  alias UptimeChecker.Helper.Strings
  alias UptimeChecker.{WatchDog, Customer}
  alias UptimeChecker.Schema.WatchDog.Check
  alias UptimeChecker.Service.{MonitorService, RegionService}
  alias UptimeChecker.Event.{HandleErrorLog, HandleApiResponse}

  def work(monitor_id) do
    tracing_id = Strings.random_string(10)
    monitor = MonitorService.get(monitor_id)

    with {:ok, org} <- Customer.get_user_contact_by_id(monitor.organization_id),
         {:ok, region} <- RegionService.get_current_region(),
         {:ok, check} <- WatchDog.create_check(%{}, monitor, region, org) do
      with {u_secs, result} <- HitApi.hit(tracing_id, monitor) do
        duration = round(u_secs / 1000)

        case result do
          {:ok, %HTTPoison.Response{} = response} ->
            Logger.info(
              "#{tracing_id} RESPONSE #{check.monitor.url} CODE ==> #{response.status_code} DURATION ==> #{duration}"
            )

            handle_response(tracing_id, response, check)

          {:error, %HTTPoison.Error{reason: reason}} ->
            Logger.error("#{tracing_id} API Request failed #{monitor.url}, reason #{reason}")
            HandleErrorLog.finalize(tracing_id, reason, check)
        end
      end
    end

    :ok
  end

  def handle_response(tracing_id, %HTTPoison.Response{} = response, %Check{} = check) do
    case HandleApiResponse.handle(response, check.monitor) do
      {:ok, _success} ->
        WatchDog.create_monitor_regions(check.monitor)

      {:error, code} ->
        HandleErrorLog.create(tracing_id, response.body, response.status_code, check, code)
    end
  end
end
