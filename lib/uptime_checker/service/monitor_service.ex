defmodule UptimeChecker.Service.MonitorService do
  import Ecto.Query, warn: false

  alias UptimeChecker.Repo
  alias UptimeChecker.Schema.WatchDog.Monitor
  alias UptimeChecker.Schema.Customer.{Organization, User}

  def update_monitor_order(%Monitor{} = monitor) do
  end

  def create(attrs \\ %{}, %User{} = user) do
    params = attrs |> Map.put(:user, user)

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
end
