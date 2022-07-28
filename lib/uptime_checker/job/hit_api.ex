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
      Api.hit(
        monitor.url,
        monitor.method,
        monitor.headers,
        monitor.body || "",
        monitor.timeout,
        monitor.follow_redirects
      )
    end

    # case :timer.tc(
    #        Api.hit(
    #          monitor.url,
    #          monitor.method,
    #          monitor.headers,
    #          monitor.body || "",
    #          monitor.timeout,
    #          monitor.follow_redirects
    #        )
    #      ) do
    #   {u_secs, :ok, %HTTPoison.Response{} = response} ->
    #     IO.inspect(u_secs)

    #   {u_secs, :error, error} ->
    #     IO.inspect(u_secs)
    # end

    :ok
  end

  defp create_check(monitor, region, org) do
    WatchDog.create_check(%{}, monitor, region, org)
  end
end
