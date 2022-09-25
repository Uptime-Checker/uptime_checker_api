defmodule UptimeChecker.Service.MonitorService do
  import Ecto.Query, warn: false

  alias UptimeChecker.Repo
  alias UptimeChecker.Schema.WatchDog.Monitor
  alias UptimeChecker.Schema.Customer.{Organization, User}

  def list(%Organization{} = organization) do
    list_recursively(organization)
    |> Repo.paginate()
  end

  def get(id), do: Repo.get(Monitor, id)

  def update_order(id, before_id, %User{} = user) do
    before = Monitor |> Repo.get_by!(id: before_id, organization_id: user.organization_id)
    current = Monitor |> Repo.get_by!(id: id, organization_id: user.organization_id)

    Ecto.Multi.new()
    |> Ecto.Multi.run(:current_m_prev_of, fn _repo, %{} ->
      Monitor |> update_after_monitor_of_current()
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
    params = attrs |> Map.put(:user, user) |> Map.put(:prev_id, nil)
    head = get_head(user.organization)

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
      {:ok, %{current_m: current_m}} ->
        {:ok, current_m}

      {:error, _name, changeset, _changes_so_far} ->
        {:error, changeset}
    end
  end

  def delete(id, %User{} = user) do
    current = Monitor |> Repo.get_by!(id: id, organization_id: user.organization_id)

    Ecto.Multi.new()
    |> Ecto.Multi.run(:current_m_prev_of, fn _repo, %{} ->
      Monitor |> update_after_monitor_of_current()
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
