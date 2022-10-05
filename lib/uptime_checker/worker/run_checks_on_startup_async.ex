defmodule UptimeChecker.Worker.RunChecksOnStartupAsync do
  require Logger

  alias UptimeChecker.Constant.Env

  use Oban.Worker, max_attempts: 1, queue: Env.current_region() |> System.get_env()

  @impl true
  def perform(%Oban.Job{args: %{}}) do
    try do
      UptimeChecker.Job.RunChecksOnStartup.work()
    rescue
      e ->
        Logger.error(e)
        Sentry.capture_exception(e, stacktrace: __STACKTRACE__, extra: %{module: __MODULE__})
    end
  end

  def enqueue() do
    %{}
    |> new(queue: Env.current_region() |> System.get_env())
    |> Oban.insert()
  end
end
