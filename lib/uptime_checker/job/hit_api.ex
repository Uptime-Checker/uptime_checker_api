defmodule UptimeChecker.Job.HitApi do
  require Logger

  alias UptimeChecker.Http.Api
  alias UptimeChecker.WatchDog
  alias UptimeChecker.Helper.String
  alias UptimeChecker.TaskSupervisor
  alias UptimeChecker.Event.HandleNextCheck
  import Plug.Conn.Status, only: [code: 1]

  def work(monitor_region_id) do
    tracing_id = String.random_string(10)

    with monitor_region = WatchDog.get_monitor_region_status_code(monitor_region_id),
         {:ok, check} <-
           create_check(monitor_region.monitor, monitor_region.region, monitor_region.monitor.organization) do
      monitor = monitor_region.monitor

      with {u_secs, result} <- hit_api(tracing_id, monitor) do
        case result do
          {:ok, %HTTPoison.Response{} = response} ->
            handle_response(tracing_id, monitor_region, check, round(u_secs / 1000), response)

          {:error, %HTTPoison.Error{reason: reason}} ->
            Logger.error("#{tracing_id} API Request failed #{monitor.url}, reason #{reason}, check #{check.id}")
        end
      end
    end

    :ok
  end

  defp handle_response(tracing_id, monitor_region, check, duration, %HTTPoison.Response{} = response) do
    Logger.info("#{tracing_id} RESPONSE #{check.monitor.url} CODE ==> #{response.status_code} DURATION ==> #{duration}")

    if response.status_code >= code(:ok) && response.status_code < code(:bad_request) do
      if is_nil(List.first(check.monitor.status_codes)) do
        HandleNextCheck.act(tracing_id, monitor_region, check, duration, true)
      else
        success_status_codes = Enum.map(check.monitor.status_codes, fn status_code -> status_code.code end)

        if Enum.member?(success_status_codes, response.status_code) do
          HandleNextCheck.act(tracing_id, monitor_region, check, duration, true)
        end
      end
    else
      create_error_log_async(response, check, :status_code_mismatch)
      HandleNextCheck.act(tracing_id, monitor_region, check, duration, false)
    end
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

  defp create_check(monitor, region, org) do
    WatchDog.create_check(%{}, monitor, region, org)
  end

  defp create_error_log_async(response, check, type) do
    attrs = %{
      text: response.body,
      status_code: response.status_code,
      type: type
    }

    Task.Supervisor.start_child(TaskSupervisor, WatchDog, :create_error_log, [attrs, check], restart: :transient)
  end
end
