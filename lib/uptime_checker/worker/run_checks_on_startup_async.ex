defmodule UptimeChecker.Worker.RunChecksOnStartupAsync do
  require Logger
  use Oban.Worker, max_attempts: 1

  @impl true
  def perform(%Oban.Job{args: %{}}) do
    try do
      UptimeChecker.Job.RunChecksOnStarup.work()
    rescue
      e ->
        Logger.error(e)
        Sentry.capture_exception(e, stacktrace: __STACKTRACE__, extra: %{module: __MODULE__})
    end
  end

  def enqueue() do
    %{}
    |> new()
    |> Oban.insert()
  end
end
