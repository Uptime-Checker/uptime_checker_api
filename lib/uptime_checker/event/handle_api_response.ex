defmodule UptimeChecker.Event.HandleApiResponse do
  require Logger

  alias UptimeChecker.Event.{HandleNextCheck, HandleErrorLog}
  alias UptimeChecker.Schema.WatchDog.{Check, MonitorRegion, Monitor}

  import Plug.Conn.Status, only: [code: 1]

  def act(
        tracing_id,
        %MonitorRegion{} = monitor_region,
        %Check{} = check,
        duration,
        %HTTPoison.Response{} = response
      ) do
    Logger.info("#{tracing_id} RESPONSE #{check.monitor.url} CODE ==> #{response.status_code} DURATION ==> #{duration}")

    case handle(response, check.monitor) do
      {:ok, success} ->
        HandleNextCheck.act(tracing_id, monitor_region, check, duration, success)

      {:error, code} ->
        handle_failure_from_response(tracing_id, response, monitor_region, check, duration, code)
    end
  end

  def handle(%HTTPoison.Response{} = response, %Monitor{} = _monitor) do
    if response.status_code >= code(:ok) && response.status_code < code(:bad_request) do
      # good status code
      {:ok, true}
    else
      # status code ranges from >= 400 to 500+
      {:error, :bad_status_code}
    end
  end

  defp handle_failure_from_response(tracing_id, response, monitor_region, check, duration, error_type) do
    HandleNextCheck.act(tracing_id, monitor_region, check, duration, false)
    HandleErrorLog.create(tracing_id, response.body, response.status_code, check, error_type)
  end
end
