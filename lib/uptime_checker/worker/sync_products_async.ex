defmodule UptimeChecker.Worker.SyncProductsAsync do
  require Logger
  use Oban.Worker, queue: :default

  alias UptimeChecker.Cron.SyncProducts

  @impl true
  def perform(%Oban.Job{} = _job) do
    try do
      SyncProducts.work()
    rescue
      e ->
        Logger.error(e)
        Sentry.capture_exception(e, stacktrace: __STACKTRACE__, extra: %{module: __MODULE__})
    end
  end
end
