defmodule UptimeChecker.WatchDogFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `UptimeChecker.WatchDog` context.
  """

  @doc """
  Generate a monitor.
  """
  def monitor_fixture(attrs \\ %{}) do
    {:ok, monitor} =
      attrs
      |> Enum.into(%{
        body: "some body",
        contains: "some contains",
        interval: 42,
        last_checked_at: ~U[2022-07-19 11:54:00Z],
        last_failed_at: ~U[2022-07-19 11:54:00Z],
        method: 42,
        name: "some name",
        resolve_threshold: 42,
        state: 42,
        timeout: 42,
        url: "some url"
      })
      |> UptimeChecker.Service.MonitorService.create()

    monitor
  end
end
