defmodule UptimeChecker.Worker.HitApi do
  use Oban.Worker

  alias UptimeChecker.Schema.MonitorRegion

  @impl true
  def perform(%Oban.Job{args: %{"monitor_region_id" => monitor_region_id}}) do
    IO.puts("Starting work...")
    IO.puts(monitor_region_id)
    IO.puts("...Finished work")
  end

  def enqueue(%MonitorRegion{id: id}) do
    %{monitor_region_id: id}
    |> new()
    |> Oban.insert()
  end
end
