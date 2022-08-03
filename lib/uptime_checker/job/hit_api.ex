defmodule UptimeChecker.Job.HitApi do
  use Timex
  require Logger

  alias UptimeChecker.WatchDog
  alias UptimeChecker.Http.Api
  alias UptimeChecker.Helper.Util
  alias UptimeChecker.TaskSupervisor
  alias UptimeChecker.{Customer, Alarm_S}
  import Plug.Conn.Status, only: [code: 1]

  def work(monitor_region_id) do
    tracing_id = Util.random_string(10)

    monitor_region = WatchDog.get_monitor_region(monitor_region_id)
    monitor = WatchDog.get_monitor_with_status_codes(monitor_region.monitor_id)
    org = Customer.get_organization(monitor.organization_id)

    with {:ok, check} <- create_check(monitor, monitor_region.region, org) do
      with {u_secs, result} <- hit_api(tracing_id, monitor) do
        case result do
          {:ok, %HTTPoison.Response{} = response} ->
            handle_response(tracing_id, monitor, monitor_region, check, u_secs / 1000, response)

          {:error, %HTTPoison.Error{reason: reason}} ->
            Logger.error("#{tracing_id} API Request failed #{monitor.url}, reason #{reason}, check #{check.id}")
        end
      end
    end

    :ok
  end

  defp handle_response(tracing_id, monitor, monitor_region, check, duration, %HTTPoison.Response{} = response) do
    Logger.info("#{tracing_id} RESPONSE #{monitor.url} CODE ==> #{response.status_code}")

    if response.status_code >= code(:ok) && response.status_code < code(:bad_request) do
      if is_nil(List.first(monitor.status_codes)) do
        handle_next_check(tracing_id, monitor, monitor_region, check, duration, true)
      else
        success_status_codes = Enum.map(monitor.status_codes, fn status_code -> status_code.code end)

        if Enum.member?(success_status_codes, response.status_code) do
          handle_next_check(tracing_id, monitor, monitor_region, check, duration, true)
        end
      end
    else
      handle_next_check(tracing_id, monitor, monitor_region, check, duration, false)

      WatchDog.create_error_log(
        %{
          text: response.body,
          status_code: response.status_code,
          type: 1
        },
        check
      )
    end
  end

  defp handle_next_check(tracing_id, monitor, monitor_region, check, duration, success) do
    now = NaiveDateTime.utc_now()

    check_params = %{
      success: success,
      duration: round(duration)
    }

    WatchDog.handle_next_check(
      monitor,
      monitor_params(success, now),
      monitor_region,
      monitor_region_params(tracing_id, success, now, monitor, monitor_region, check),
      check,
      check_params
    )
  end

  defp monitor_params(success, now) when success == true, do: %{last_checked_at: now}
  defp monitor_params(success, now) when success == false, do: %{last_checked_at: now, last_failed_at: now}

  defp monitor_region_params(_tracing_id, success, now, monitor, _monitor_region, _check) when success == true do
    %{
      last_checked_at: now,
      next_check_at: Timex.shift(now, seconds: +monitor.interval)
    }
  end

  defp monitor_region_params(tracing_id, success, now, monitor, monitor_region, check) when success == false do
    consequtive_failure = monitor_region.consequtive_failure + 1

    Task.Supervisor.start_child(TaskSupervisor, Alarm_S, :raise_alarm, [tracing_id, check, consequtive_failure],
      restart: :transient
    )

    %{
      last_checked_at: now,
      next_check_at: Timex.shift(now, seconds: +monitor.interval),
      consequtive_failure: consequtive_failure,
      consequtive_recovery: 0
    }
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
end
