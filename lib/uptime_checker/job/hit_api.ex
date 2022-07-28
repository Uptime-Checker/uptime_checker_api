defmodule UptimeChecker.Job.HitApi do
  require Logger

  alias UptimeChecker.Customer
  alias UptimeChecker.WatchDog
  alias UptimeChecker.Http.Api

  def work(monitor_region_id) do
    monitor_region = WatchDog.get_monitor_region(monitor_region_id)
    monitor = monitor_region.monitor
    org = Customer.get_organization(monitor.organization_id)

    with {:ok, check} <- create_check(monitor, monitor_region.region, org) do
      with {u_secs, result} <- hit_api(monitor) do
        case result do
          {:ok, %HTTPoison.Response{} = response} ->
            handle_response(u_secs / 1000, response)

          {:error, %HTTPoison.Error{reason: reason}} ->
            Logger.error("API Request failed #{monitor.url}, reason #{reason}, check #{check.id}")
        end
      end
    end

    :ok
  end

  defp handle_response(duration, %HTTPoison.Response{} = response) do
    IO.inspect(duration)
    IO.inspect(response)
  end

  defp hit_api(monitor) do
    :timer.tc(fn ->
      Api.hit(
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
