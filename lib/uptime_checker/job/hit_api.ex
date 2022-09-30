defmodule UptimeChecker.Job.HitApi do
  require Logger

  alias UptimeChecker.Http.Api
  alias UptimeChecker.WatchDog
  alias UptimeChecker.Helper.Strings
  alias UptimeChecker.Schema.WatchDog.{MonitorRegion, Check}
  alias UptimeChecker.Event.{HandleNextCheck, HandleErrorLog}

  import Plug.Conn.Status, only: [code: 1]

  def work(monitor_region_id) do
    tracing_id = Strings.random_string(10)

    with {:ok, %MonitorRegion{} = monitor_region} <- WatchDog.get_monitor_region_status_code(monitor_region_id),
         {:ok, check} <-
           create_check(
             tracing_id,
             monitor_region.monitor,
             monitor_region.region,
             monitor_region.monitor.organization
           ) do
      monitor = monitor_region.monitor

      with {u_secs, result} <- hit_api(tracing_id, monitor) do
        duration = round(u_secs / 1000)

        case result do
          {:ok, %HTTPoison.Response{} = response} ->
            handle_response(tracing_id, monitor_region, check, duration, response)

          {:error, %HTTPoison.Error{reason: reason}} ->
            Logger.error("#{tracing_id} API Request failed #{monitor.url}, reason #{reason}, check #{check.id}")
            handle_failure_from_poison(tracing_id, reason, monitor_region, check, duration)
        end
      end
    end

    :ok
  end

  defp handle_response(
         tracing_id,
         %MonitorRegion{} = monitor_region,
         %Check{} = check,
         duration,
         %HTTPoison.Response{} = response
       ) do
    Logger.info("#{tracing_id} RESPONSE #{check.monitor.url} CODE ==> #{response.status_code} DURATION ==> #{duration}")

    if response.status_code >= code(:ok) && response.status_code < code(:bad_request) do
      # good status code
      if is_nil(List.first(check.monitor.status_codes)) do
        HandleNextCheck.act(tracing_id, monitor_region, check, duration, true)
      else
        success_status_codes = Enum.map(check.monitor.status_codes, fn status_code -> status_code.code end)

        if Enum.member?(success_status_codes, response.status_code) do
          HandleNextCheck.act(tracing_id, monitor_region, check, duration, true)
        else
          handle_failure_from_response(tracing_id, response, monitor_region, check, duration, :status_code_mismatch)
        end
      end
    else
      # status code ranges from >= 400 to 500+
      handle_failure_from_response(tracing_id, response, monitor_region, check, duration, :bad_status_code)
    end
  end

  defp handle_failure_from_response(tracing_id, response, monitor_region, check, duration, error_type) do
    HandleNextCheck.act(tracing_id, monitor_region, check, duration, false)
    HandleErrorLog.create(tracing_id, response.body, response.status_code, check, error_type)
  end

  defp hit_api(tracing_id, monitor) do
    :timer.tc(fn ->
      Api.hit(
        tracing_id,
        monitor.url,
        monitor.method,
        monitor.headers,
        monitor.body || "",
        monitor.timeout,
        monitor.follow_redirects
      )
    end)
  end

  defp create_check(tracing_id, monitor, region, org) do
    case WatchDog.create_check(%{}, monitor, region, org) do
      {:ok, %Check{} = check} ->
        Logger.debug("#{tracing_id} 1 Created new check #{check.id}")
        {:ok, check}

      {:error, %Ecto.Changeset{} = changeset} ->
        Logger.error("#{tracing_id} 2 Failed to create check, error: #{inspect(changeset.errors)}")
        {:error, changeset}
    end
  end

  defp handle_failure_from_poison(tracing_id, reason, monitor_region, check, duration) do
    HandleNextCheck.act(tracing_id, monitor_region, check, duration, false)
    HandleErrorLog.finalize(tracing_id, reason, check)
  end
end
