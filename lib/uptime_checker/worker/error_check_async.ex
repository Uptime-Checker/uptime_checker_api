defmodule UptimeChecker.Worker.ErrorCheckAsync do
  require Logger
  use Oban.Worker, queue: :default

  alias UptimeChecker.Cron.ErrorCheck

  @impl true
  def perform(%Oban.Job{} = _job) do
    try do
      ErrorCheck.work()
    rescue
      e ->
        Logger.error(e)
        Sentry.capture_exception(e, stacktrace: __STACKTRACE__, extra: %{module: __MODULE__})
    end
  end
end
