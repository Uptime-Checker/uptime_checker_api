defmodule UptimeChecker.Worker.StartMonitorAsync do
  require Logger
  use Oban.Worker, max_attempts: 1, unique: [period: 15], queue: :default

  alias UptimeChecker.Schema.WatchDog.Monitor

  @impl true
  def perform(%Oban.Job{args: %{"monitor_id" => monitor_id}}) do
    try do
      UptimeChecker.Job.StartMonitor.work(monitor_id)
    rescue
      e ->
        Logger.error(e)
        Sentry.capture_exception(e, stacktrace: __STACKTRACE__, extra: %{module: __MODULE__})
    end
  end

  def enqueue(%Monitor{id: id}) do
    %{monitor_id: id}
    |> new(queue: :default)
    |> Oban.insert()
  end
end
