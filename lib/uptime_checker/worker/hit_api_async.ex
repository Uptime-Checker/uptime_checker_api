defmodule UptimeChecker.Worker.HitApiAsync do
  require Logger
  use Oban.Worker, max_attempts: 1, unique: [period: 10]

  alias UptimeChecker.Schema.WatchDog.MonitorRegion

  @impl true
  def perform(%Oban.Job{args: %{"monitor_region_id" => monitor_region_id}}) do
    try do
      UptimeChecker.Job.HitApi.work(monitor_region_id)
    rescue
      e ->
        Logger.error(e)
    end
  end

  def enqueue(%MonitorRegion{id: id, next_check_at: next_check_at}) do
    %{monitor_region_id: id}
    |> new(scheduled_at: next_check_at)
    |> Oban.insert()
  end
end
