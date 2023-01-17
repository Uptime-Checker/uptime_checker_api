defmodule UptimeChecker.Event.InitStart do
  alias UptimeChecker.Worker

  def run() do
    Worker.RunChecksOnStartupAsync.enqueue()
  end
end
