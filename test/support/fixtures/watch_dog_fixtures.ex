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
        status_codes: [],
        timeout: 42,
        url: "some url"
      })
      |> UptimeChecker.WatchDog.create_monitor()

    monitor
  end

  @doc """
  Generate a region.
  """
  def region_fixture(attrs \\ %{}) do
    {:ok, region} =
      attrs
      |> Enum.into(%{
        ip_address: "some ip_address",
        key: "some key",
        name: "some name"
      })
      |> UptimeChecker.WatchDog.create_region()

    region
  end

  @doc """
  Generate a check.
  """
  def check_fixture(attrs \\ %{}) do
    {:ok, check} =
      attrs
      |> Enum.into(%{
        duration: 120.5,
        success: true
      })
      |> UptimeChecker.WatchDog.create_check()

    check
  end
end
