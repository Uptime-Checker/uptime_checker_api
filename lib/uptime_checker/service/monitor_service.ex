defmodule UptimeChecker.Service.MonitorService do
  use Timex
  import Ecto.Query, warn: false

  alias UptimeChecker.Repo
  alias UptimeChecker.Error.RepoError
  alias UptimeChecker.Constant.Default
  alias UptimeChecker.Schema.Customer.{Organization, User}
  alias UptimeChecker.Schema.WatchDog.{Monitor, MonitorStatusChange}

  def list_all(on, down, cursor) do
    query =
      from m in Monitor,
        where: m.on == ^on,
        where: m.down == ^down

    query
    |> Repo.paginate(after: cursor)
  end

  def list(%Organization{} = organization, offset) do
    list_recursively(organization) |> limit(^Default.offset_limit()) |> offset(^offset) |> Repo.all()
  end

  def get(id), do: Repo.get(Monitor, id)

  def get_with_all_assoc(id) do
    query =
      from m in Monitor,
        where: m.id == ^id,
        left_join: o in assoc(m, :organization),
        left_join: status_codes in assoc(m, :status_codes),
        preload: [organization: o, status_codes: status_codes]

    Repo.one(query)
    |> case do
      nil -> {:error, RepoError.monitor_not_found() |> ErrorMessage.not_found(%{id: id})}
      monitor -> {:ok, monitor}
    end
  end

  def pause_monitor(%Monitor{} = monitor, on) do
    now = Timex.now()

    Ecto.Multi.new()
    |> Ecto.Multi.update(:monitor, monitor |> Monitor.pause_changeset(%{on: on}))
    |> Ecto.Multi.insert(
      :monitor_status_change,
      MonitorStatusChange.changeset(%MonitorStatusChange{}, %{status: :paused, changed_at: now, monitor: monitor})
    )
    |> Repo.transaction()
    |> case do
      {:ok, %{monitor: monitor, monitor_status_change: _monitor_status_change}} ->
        {:ok, monitor}

      {:error, _name, changeset, _changes_so_far} ->
        {:error, changeset}
    end
  end

  def update_order(id, before_id, %User{} = user) do
    before = Monitor |> Repo.get_by!(id: before_id, organization_id: user.organization_id)
    current = Monitor |> Repo.get_by!(id: id, organization_id: user.organization_id)

    Ecto.Multi.new()
    |> Ecto.Multi.run(:current_m_prev_of, fn _repo, %{} ->
      current |> update_after_monitor_of_current()
    end)
    |> Ecto.Multi.update(:before_m, Monitor.update_order_changeset(before, %{prev_id: current.id}))
    |> Ecto.Multi.update(:current_m, Monitor.update_order_changeset(current, %{prev_id: before.prev_id}))
    |> Repo.transaction()
    |> case do
      {:ok, %{current_m_prev_of: _current_m_prev_of, before_m: _before_m, current_m: current_m}} ->
        {:ok, current_m}

      {:error, _name, changeset, _changes_so_far} ->
        {:error, changeset}
    end
  end

  def create(attrs \\ %{}, %User{} = user) do
    head = get_head(user.organization)
    params = attrs |> Map.put(:user, user) |> Map.put(:prev_id, nil)

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:current_m, %Monitor{} |> Monitor.changeset(params))
    |> Ecto.Multi.run(:head_m, fn _repo, %{current_m: current_m} ->
      case head do
        nil ->
          {:ok, 0}

        id ->
          Monitor
          |> where(id: ^id)
          |> update(set: [prev_id: ^current_m.id])
          |> Repo.update_all([])
          |> case do
            {count, nil} ->
              {:ok, count}
          end
      end
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{current_m: current_m, head_m: _head_m}} ->
        {:ok, current_m}

      {:error, _name, changeset, _changes_so_far} ->
        {:error, changeset}
    end
  end

  def delete(id, %User{} = user) do
    current = Monitor |> Repo.get_by!(id: id, organization_id: user.organization_id)

    Ecto.Multi.new()
    |> Ecto.Multi.run(:current_m_prev_of, fn _repo, %{} ->
      current |> update_after_monitor_of_current()
    end)
    |> Ecto.Multi.delete(:current_m, current)
    |> Repo.transaction()
    |> case do
      {:ok, %{current_m_prev_of: _current_m_prev_of, current_m: current_m}} ->
        {:ok, current_m}

      {:error, _name, changeset, _changes_so_far} ->
        {:error, changeset}
    end
  end

  def count(%Organization{} = organization) do
    query =
      from m in Monitor,
        where: m.organization_id == ^organization.id,
        select: count(m.id)

    Repo.one(query)
  end

  defp update_after_monitor_of_current(%Monitor{} = current) do
    Monitor
    |> where(prev_id: ^current.id)
    |> update(set: [prev_id: ^current.prev_id])
    |> Repo.update_all([])
    |> case do
      {count, nil} ->
        {:ok, count}
    end
  end

  defp list_recursively(%Organization{} = organization) do
    monitor_tree_initial_query =
      Monitor
      |> where([m], is_nil(m.prev_id))

    monitor_tree_recursion_query =
      Monitor
      |> join(:inner, [m], mt in "monitor_tree", on: m.prev_id == mt.id)

    monitor_tree_query =
      monitor_tree_initial_query
      |> union(^monitor_tree_recursion_query)

    {"monitor_tree", Monitor}
    |> recursive_ctes(true)
    |> with_cte("monitor_tree", as: ^monitor_tree_query)
    |> where(organization_id: ^organization.id)
  end

  defp get_head(%Organization{} = organization) do
    monitors =
      list_recursively(organization)
      |> limit(1)
      |> Repo.all()

    if Enum.count(monitors) == 1 do
      monitor = Enum.at(monitors, 0)
      monitor.id
    else
      nil
    end
  end
end
