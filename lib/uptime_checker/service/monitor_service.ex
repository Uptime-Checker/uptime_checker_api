defmodule UptimeChecker.Service.MonitorService do
  import Ecto.Query, warn: false

  alias UptimeChecker.Repo
  alias UptimeChecker.Schema.WatchDog.Monitor
  alias UptimeChecker.Schema.Customer.{Organization, User}

  def list do
    Repo.all(Monitor)
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
    params = attrs |> Map.put(:user, user) |> Map.put(:prev_id, user.organization |> get_prev_of_org())

    %Monitor{}
    |> Monitor.changeset(params)
    |> Repo.insert()
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

  defp get_prev_of_org(%Organization{} = organization) do
    query =
      from m in Monitor,
        where: m.organization_id == ^organization.id,
        # coalesce treats null as 0
        order_by: [desc: fragment("coalesce(?, 0)", m.prev_id)],
        limit: 1

    query
    |> Repo.one()
    |> case do
      nil -> nil
      monitor -> monitor.id
    end
  end
end
