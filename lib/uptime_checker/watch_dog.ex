defmodule UptimeChecker.WatchDog do
  @moduledoc """
  The WatchDog context.
  """
  use Timex

  import Ecto.Query, warn: false
  import UptimeChecker.Helper.Util

  alias UptimeChecker.Repo
  alias UptimeChecker.Region_S
  alias UptimeChecker.Schema.{Region, MonitorRegion}
  alias UptimeChecker.Schema.WatchDog.{Monitor, Check, ErrorLog}

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
    |> Repo.preload([:region])
  end

  def create_monitor(attrs \\ %{}, user) do
    params = key_to_atom(attrs) |> Map.put(:user, user)

    %Monitor{}
    |> Monitor.changeset(params)
    |> Repo.insert()
  end

  def create_monitor_regions(monitor) do
    regions = Region_S.list_regions()

    Enum.each(regions, fn region ->
      %MonitorRegion{}
      |> MonitorRegion.changeset(%{
        monitor_id: monitor.id,
        region_id: region.id
      })
      |> Repo.insert()
    end)
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

  def handle_next_check(monitor, monitor_params, monitor_region, monitor_region_params, check, check_params) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:monitor, Monitor.update_check_changeset(monitor, monitor_params))
    |> Ecto.Multi.update(:monitor_region, MonitorRegion.update_check_changeset(monitor_region, monitor_region_params))
    |> Ecto.Multi.update(:check, Check.update_changeset(check, check_params))
    |> Repo.transaction()
    |> case do
      {:ok, %{monitor: monitor, monitor_region: monitor_region, check: check}} ->
        {:ok, monitor, monitor_region, check}

      {:error, _name, changeset, _changes_so_far} ->
        {:error, changeset}
    end
  end

  def update_check(%Check{} = check, attrs) do
    check
    |> Check.update_changeset(attrs)
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

  def create_error_log(attrs \\ %{}, check) do
    params = attrs |> Map.put(:check, check)

    %ErrorLog{}
    |> ErrorLog.changeset(params)
    |> Repo.insert()
  end
end
