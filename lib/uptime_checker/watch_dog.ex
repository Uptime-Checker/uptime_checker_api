defmodule UptimeChecker.WatchDog do
  @moduledoc """
  The WatchDog context.
  """
  use Timex

  import UptimeChecker.Helper.Util
  import Ecto.Query, warn: false
  alias UptimeChecker.Repo

  alias UptimeChecker.Region_S
  alias UptimeChecker.Schema.MonitorRegion
  alias UptimeChecker.Schema.WatchDog.Monitor

  def list_monitors do
    Repo.all(Monitor)
  end

  def get_monitor(id), do: Repo.get(Monitor, id)

  def get_monitor_with_status_codes(id) do
    Repo.get(Monitor, id)
    |> Repo.preload([:status_codes])
  end

  def get_monitor_region(id) do
    Repo.get(MonitorRegion, id)
    |> Repo.preload([:monitor])
    |> Repo.preload([:region])
  end

  def create_monitor(attrs \\ %{}, user) do
    params = key_to_atom(attrs) |> Map.put(:user, user)

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:monitor, Monitor.changeset(%Monitor{}, params))
    |> Ecto.Multi.insert(:monitor_region, fn %{monitor: updated_monitor} ->
      region = Region_S.get_default_region()

      %MonitorRegion{}
      |> MonitorRegion.changeset(%{
        region_id: region.id,
        next_check_at: Timex.shift(NaiveDateTime.utc_now(), minutes: +1)
      })
      |> Ecto.Changeset.put_assoc(:monitor, updated_monitor)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{monitor: monitor, monitor_region: monitor_region}} ->
        {:ok, get_monitor(monitor.id), monitor_region}

      {:error, _name, changeset, _changes_so_far} ->
        {:error, changeset}
    end
  end

  def list_monitor_region(from, to) do
    now = NaiveDateTime.utc_now()
    prev = Timex.shift(now, seconds: from)
    later = Timex.shift(now, seconds: to)

    query =
      from mr in MonitorRegion,
        where:
          (mr.next_check_at > ^prev and mr.next_check_at < ^later and
             mr.last_checked_at < ^prev) or is_nil(mr.last_checked_at)

    Repo.all(query)
  end

  @doc """
  Updates a monitor.

  ## Examples

      iex> update_monitor(monitor, %{field: new_value})
      {:ok, %Monitor{}}

      iex> update_monitor(monitor, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_monitor(%Monitor{} = monitor, attrs) do
    monitor
    |> Monitor.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a monitor.

  ## Examples

      iex> delete_monitor(monitor)
      {:ok, %Monitor{}}

      iex> delete_monitor(monitor)
      {:error, %Ecto.Changeset{}}

  """
  def delete_monitor(%Monitor{} = monitor) do
    Repo.delete(monitor)
  end

  def change_monitor(%Monitor{} = monitor, attrs \\ %{}) do
    Monitor.changeset(monitor, attrs)
  end

  alias UptimeChecker.Schema.Region

  def list_regions do
    Repo.all(Region)
  end

  def get_region!(id), do: Repo.get!(Region, id)

  def create_region(attrs \\ %{}) do
    %Region{}
    |> Region.changeset(attrs)
    |> Repo.insert()
  end

  def update_region(%Region{} = region, attrs) do
    region
    |> Region.changeset(attrs)
    |> Repo.update()
  end

  def delete_region(%Region{} = region) do
    Repo.delete(region)
  end

  def change_region(%Region{} = region, attrs \\ %{}) do
    Region.changeset(region, attrs)
  end

  alias UptimeChecker.Schema.WatchDog.Check

  def list_checks do
    Repo.all(Check)
  end

  def get_check!(id), do: Repo.get!(Check, id)

  def create_check(attrs \\ %{}, monitor, region, organization) do
    params =
      attrs
      |> Map.put(:monitor, monitor)
      |> Map.put(:region, region)
      |> Map.put(:organization, organization)

    %Check{}
    |> Check.changeset(params)
    |> Repo.insert()
  end

  @doc """
  Updates a check.

  ## Examples

      iex> update_check(check, %{field: new_value})
      {:ok, %Check{}}

      iex> update_check(check, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_check(%Check{} = check, attrs) do
    check
    |> Check.changeset(attrs)
    |> Repo.update()
  end

  def delete_check(%Check{} = check) do
    Repo.delete(check)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking check changes.

  ## Examples

      iex> change_check(check)
      %Ecto.Changeset{data: %Check{}}

  """
  def change_check(%Check{} = check, attrs \\ %{}) do
    Check.changeset(check, attrs)
  end
end
