defmodule UptimeChecker.Service.MonitorService do
  import Ecto.Query, warn: false

  alias UptimeChecker.Repo
  alias UptimeChecker.Schema.WatchDog.Monitor
  alias UptimeChecker.Schema.Customer.{Organization, User}

  def update_order(%Monitor{} = monitor) do
  end

  def create(attrs \\ %{}, %User{} = user) do
    params = attrs |> Map.put(:user, user) |> Map.put(:prev_id, user.organization |> get_prev())

    %Monitor{}
    |> Monitor.changeset(params)
    |> Repo.insert()
  end

  def count(%Organization{} = organization) do
    query =
      from m in Monitor,
        where: m.organization_id == ^organization.id,
        select: count(m.id)

    Repo.one(query)
  end

  defp get_prev(%Organization{} = organization) do
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
