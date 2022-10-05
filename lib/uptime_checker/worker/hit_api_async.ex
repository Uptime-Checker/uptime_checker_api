defmodule UptimeChecker.Worker.HitApiAsync do
  require Logger

  alias UptimeChecker.Constant.Env
  alias UptimeChecker.Schema.WatchDog.MonitorRegion

  use Oban.Worker, max_attempts: 1, unique: [period: 15], queue: Env.current_region() |> System.get_env()

  @impl true
  def perform(%Oban.Job{args: %{"monitor_region_id" => monitor_region_id}}) do
    try do
      UptimeChecker.Job.HitApi.work(monitor_region_id)
    rescue
      e ->
        Logger.error(e)
        Sentry.capture_exception(e, stacktrace: __STACKTRACE__, extra: %{module: __MODULE__})
    end
  end

  def enqueue(%MonitorRegion{id: id, next_check_at: next_check_at}) do
    %{monitor_region_id: id}
    |> new(queue: Env.current_region() |> System.get_env(), scheduled_at: next_check_at)
    |> Oban.insert()
  end
end
