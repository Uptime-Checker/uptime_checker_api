defmodule UptimeChecker.Job.HitApi do
  require Logger

  alias UptimeChecker.Http.Api
  alias UptimeChecker.WatchDog
  alias UptimeChecker.Schema.Region
  alias UptimeChecker.Helper.Strings
  alias UptimeChecker.Schema.WatchDog.{MonitorRegion, Check, Monitor}
  alias UptimeChecker.Event.{HandleNextCheck, HandleErrorLog, HandleApiResponse}

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

      with {u_secs, result} <- hit(tracing_id, monitor) do
        duration = round(u_secs / 1000)

        case result do
          {:ok, %HTTPoison.Response{} = response} ->
            HandleApiResponse.act(tracing_id, monitor_region, check, duration, response)

          {:error, %HTTPoison.Error{reason: reason}} ->
            Logger.error("#{tracing_id} API Request failed #{monitor.url}, reason #{reason}, check #{check.id}")
            handle_failure_from_poison(tracing_id, reason, monitor_region, check, duration)
        end
      end
    end

    :ok
  end

  def hit(tracing_id, %Monitor{} = monitor) do
    :timer.tc(fn ->
      Api.hit(
        tracing_id,
        monitor.url,
        monitor.method,
        monitor.headers,
        monitor.body || "",
        monitor.body_format,
        monitor.timeout,
        monitor.follow_redirects
      )
    end)
  end

  defp create_check(tracing_id, %Monitor{} = monitor, %Region{} = region, org) do
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
