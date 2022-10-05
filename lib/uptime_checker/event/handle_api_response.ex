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

  def handle(%HTTPoison.Response{} = response, %Monitor{} = monitor) do
    if response.status_code >= code(:ok) && response.status_code < code(:bad_request) do
      # good status code
      if is_nil(List.first(monitor.status_codes)) do
        {:ok, true}
      else
        success_status_codes = Enum.map(monitor.status_codes, fn status_code -> status_code.code end)

        if Enum.member?(success_status_codes, response.status_code) do
          {:ok, true}
        else
          {:error, :status_code_mismatch}
        end
      end
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
