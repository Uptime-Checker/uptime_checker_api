defmodule UptimeChecker.Job.HitApi do
  require Logger

  alias UptimeChecker.Http.Api
  alias UptimeChecker.WatchDog
  alias UptimeChecker.Constant
  alias UptimeChecker.Helper.Strings
  alias UptimeChecker.Event.HandleNextCheck
  alias UptimeChecker.Schema.WatchDog.MonitorRegion

  import Plug.Conn.Status, only: [code: 1]

  def work(monitor_region_id) do
    tracing_id = Strings.random_string(10)

    with {:ok, %MonitorRegion{} = monitor_region} <- WatchDog.get_monitor_region_status_code(monitor_region_id),
         {:ok, check} <-
           create_check(monitor_region.monitor, monitor_region.region, monitor_region.monitor.organization) do
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

  defp handle_response(tracing_id, monitor_region, check, duration, %HTTPoison.Response{} = response) do
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
    create_error_log(response.body, response.status_code, check, error_type)
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

  defp handle_failure_from_poison(tracing_id, reason, monitor_region, check, duration) do
    HandleNextCheck.act(tracing_id, monitor_region, check, duration, false)

    case reason do
      :nxdomain ->
        create_error_log(Constant.Api.error_host_or_domain_not_found(), -1, check, :nxdomain)

      :etimedout ->
        create_error_log(Constant.Api.error_connection_timed_out(), -2, check, :etimedout)

      :etime ->
        create_error_log(Constant.Api.error_timer_expired(), -3, check, :etime)

      :erefused ->
        create_error_log(Constant.Api.error_erefused(), -4, check, :erefused)

      :epipe ->
        create_error_log(Constant.Api.error_broken_pipe(), -5, check, :epipe)

      :enospc ->
        create_error_log(Constant.Api.error_no_space_left_on_device(), -6, check, :enospc)

      :enomem ->
        create_error_log(Constant.Api.error_not_enough_memory(), -7, check, :enomem)

      :enoent ->
        create_error_log(Constant.Api.error_no_such_file_or_directory(), -8, check, :enoent)

      :enetdown ->
        create_error_log(Constant.Api.error_network_is_down(), -9, check, :enetdown)

      :emfile ->
        create_error_log(Constant.Api.error_too_many_open_files(), -10, check, :emfile)

      :ehostunreach ->
        create_error_log(Constant.Api.host_or_domain_not_found(), -11, check, :ehostunreach)

      :ehostdown ->
        create_error_log(Constant.Api.error_host_is_down(), -12, check, :ehostdown)

      :econnreset ->
        create_error_log(Constant.Api.error_connection_reset_by_peer(), -13, check, :econnreset)

      :econnrefused ->
        create_error_log(Constant.Api.error_connection_refused(), -14, check, :econnrefused)

      :econnaborted ->
        create_error_log(Constant.Api.error_connection_aborted(), -15, check, :econnaborted)

      :ecomm ->
        create_error_log(Constant.Api.error_communication_error_on_send(), -16, check, :ecomm)

      :timeout ->
        create_error_log(Constant.Api.error_request_timed_out(), -17, check, :timeout)

      other ->
        create_error_log(other, -1000, check, :ebad)
    end
  end

  defp create_error_log(text, code, check, type) do
    attrs = %{
      text: text,
      status_code: code,
      type: type
    }

    WatchDog.create_error_log(attrs, check)
  end
end
