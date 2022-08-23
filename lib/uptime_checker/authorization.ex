defmodule UptimeChecker.Authorization do
  import Ecto.Query, warn: false

  alias UptimeChecker.Repo
  alias UptimeChecker.Error.RepoError
  alias UptimeChecker.Schema.Customer.Role

  def create_role(attrs \\ %{}) do
    %Role{}
    |> Role.changeset(attrs)
    |> Repo.insert()
  end

  def get_role!(id), do: Repo.get!(Role, id)

  def get_role(id) do
    Role
    |> Repo.get(id)
    |> case do
      nil -> {:error, RepoError.role_not_found() |> ErrorMessage.not_found(%{id: id})}
      role -> {:ok, role}
    end
  end

  def get_role_by_type!(type) do
    Role
    |> Repo.get_by!(type: type)
  end

  def list_roles do
    Repo.all(Role)
  end
end
