defmodule UptimeChecker.Authorization do
  import Ecto.Query, warn: false
  alias UptimeChecker.Repo
  alias UptimeChecker.Schema.Customer.Role

  def create_role(attrs \\ %{}) do
    %Role{}
    |> Role.changeset(attrs)
    |> Repo.insert()
  end

  def get_role!(id), do: Repo.get!(Role, id)

  def list_roles do
    Repo.all(Role)
  end
end
