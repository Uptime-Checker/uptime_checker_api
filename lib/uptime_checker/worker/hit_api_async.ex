defmodule UptimeChecker.Worker.HitApiAsync do
  require Logger
  use Oban.Worker, max_attempts: 1

  alias UptimeChecker.Schema.MonitorRegion

  @impl true
  def perform(%Oban.Job{args: %{"monitor_region_id" => monitor_region_id}}) do
    try do
      UptimeChecker.Job.HitApi.work(monitor_region_id)
    rescue
      e ->
        Logger.error(e)
    end
  end

  def enqueue(%MonitorRegion{id: id}) do
    %{monitor_region_id: id}
    |> new()
    |> Oban.insert()
  end
end
