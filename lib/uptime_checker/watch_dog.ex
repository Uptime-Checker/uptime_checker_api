defmodule UptimeChecker.WatchDog do
  @moduledoc """
  The WatchDog context.
  """
  use Timex
  import Ecto.Query, warn: false

  alias UptimeChecker.Repo
  alias UptimeChecker.Customer
  alias UptimeChecker.Error.RepoError
  alias UptimeChecker.Schema.Customer.User
  alias UptimeChecker.Service.RegionService
  alias UptimeChecker.Schema.{MonitorUser, Region}
  alias UptimeChecker.Schema.WatchDog.{Monitor, Check, MonitorRegion, ErrorLog, MonitorStatusChange}

  def get_monitor_region_with_all_assoc(id) do
    query =
      from mr in MonitorRegion,
        left_join: m in assoc(mr, :monitor),
        left_join: r in assoc(mr, :region),
        left_join: o in assoc(m, :organization),
        where: mr.id == ^id,
        preload: [monitor: {m, organization: o}, region: r]

    Repo.one(query)
    |> case do
      nil -> {:error, RepoError.monitor_region_not_found() |> ErrorMessage.not_found(%{id: id})}
      monitor_region -> {:ok, monitor_region}
    end
  end

  def create_monitor_regions(%Monitor{} = monitor) do
    now = Timex.now()
    regions = RegionService.list_regions()

    # Start first one in 11 seconds and later ones will be 22/33/44/55 seconds plus
    Enum.scan(regions, 11, fn region, interval ->
      %MonitorRegion{}
      |> MonitorRegion.changeset(%{
        monitor_id: monitor.id,
        region_id: region.id,
        next_check_at: Timex.shift(now, seconds: +interval)
      })
      |> Repo.insert()

      interval + 11
    end)
  end

  def list_monitors_to_run(from, to) do
    now = Timex.now()
    prev = Timex.shift(now, seconds: from)
    later = Timex.shift(now, seconds: to)

    query =
      from m in Monitor,
        where:
          (m.next_check_at > ^prev and m.next_check_at < ^later and
             m.last_checked_at < ^prev and m.on == true) or is_nil(m.last_checked_at)

    Repo.all(query)
  end

  def list_oldest_checked_monitor_region(monitor_id) do
    query =
      from m in MonitorRegion,
        left_join: region in assoc(m, :region),
        where: m.monitor_id == ^monitor_id,
        preload: [region: region],
        order_by: [desc: m.last_checked_at],
        limit: 1

    Repo.one(query)
  end

  def list_active_monitors(cursor) do
    now = Timex.now()
    later = Timex.shift(now, seconds: 2)

    query =
      from m in Monitor,
        where: m.next_check_at < ^later and m.on == true,
        order_by: [desc: m.next_check_at]

    query
    |> Repo.paginate(after: cursor)
  end

  def update_monitor_region(%MonitorRegion{} = monitor_region, attrs) do
    monitor_region
    |> MonitorRegion.changeset(attrs)
    |> Repo.update()
  end

  def count_monitor_region(monitor_id) do
    query =
      from mr in MonitorRegion,
        where: mr.monitor_id == ^monitor_id,
        select: count(mr.id)

    Repo.one(query)
  end

  def count_monitor_region_by_status(monitor_id, is_down) do
    query =
      from mr in MonitorRegion,
        where: mr.monitor_id == ^monitor_id and mr.down == ^is_down,
        select: count(mr.id)

    Repo.one(query)
  end

  def create_monitor_users(%Monitor{} = monitor, user_ids) do
    Enum.each(user_ids, fn user_id ->
      with {:ok, %User{} = user} <- Customer.get_customer_by_id(user_id) do
        if monitor.organization_id == user.organization_id do
          %MonitorUser{}
          |> MonitorUser.changeset(%{monitor: monitor, user: user})
          |> Repo.insert()
        end
      end
    end)
  end

  def list_monitor_users_contacts(monitor_id) do
    query =
      from mu in MonitorUser,
        left_join: u in assoc(mu, :user),
        right_join: uc in assoc(u, :user_contacts),
        where: mu.monitor_id == ^monitor_id,
        select: uc

    Repo.all(query)
  end

  def update_monitor_status(%Monitor{} = monitor, attrs) do
    monitor
    |> Monitor.update_alarm_changeset(attrs)
    |> Repo.update()
  end

  def update_monitor(%Monitor{} = monitor, attrs) do
    monitor
    |> Monitor.update_changeset(attrs)
    |> Repo.update()
  end

  def list_checks do
    Repo.all(Check)
  end

  def get_check!(id), do: Repo.get!(Check, id)

  def create_check(attrs \\ %{}, %Monitor{} = monitor, %Region{} = region, organization) do
    params =
      attrs
      |> Map.put(:monitor, monitor)
      |> Map.put(:region, region)
      |> Map.put(:organization, organization)

    %Check{}
    |> Check.changeset(params)
    |> Repo.insert()
  end

  def handle_next_check(
        %Monitor{} = monitor,
        monitor_params,
        %MonitorRegion{} = monitor_region,
        monitor_region_params,
        %Check{} = check,
        check_params
      ) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:monitor, Monitor.update_changeset(monitor, monitor_params))
    |> Ecto.Multi.update(:monitor_region, MonitorRegion.update_changeset(monitor_region, monitor_region_params))
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

  def create_error_log(attrs \\ %{}, %Check{} = check, %Monitor{} = monitor) do
    params = attrs |> Map.put(:check, check) |> Map.put(:monitor, monitor)

    %ErrorLog{}
    |> ErrorLog.changeset(params)
    |> Repo.insert()
  end

  def create_monitor_status_change(status, %Monitor{} = monitor) do
    now = Timex.now()

    %MonitorStatusChange{}
    |> MonitorStatusChange.changeset(%{status: status, changed_at: now, monitor: monitor})
    |> Repo.insert()
  end

  def get_latest_monitor_status_change(monitor_id) do
    query =
      from m in MonitorStatusChange,
        where: m.monitor_id == ^monitor_id,
        order_by: [desc: m.id],
        limit: 1

    Repo.one(query)
  end
end
