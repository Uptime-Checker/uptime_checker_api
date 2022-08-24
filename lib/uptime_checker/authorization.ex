defmodule UptimeChecker.Authorization do
  import Ecto.Query, warn: false

  alias UptimeChecker.Repo
  alias UptimeChecker.Error.RepoError
  alias UptimeChecker.Schema.Customer.{Role, OrganizationUser}

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

  def create_organization_user(attrs) do
    %OrganizationUser{}
    |> OrganizationUser.changeset(attrs)
    |> Repo.insert()
  end

  def get_organization_user(organization, user) do
    OrganizationUser
    |> Repo.get_by(organization_id: organization.id, user_id: user.id)
    |> case do
      nil ->
        {:error,
         RepoError.organization_user_not_found()
         |> ErrorMessage.not_found(%{organization_id: organization.id, user: user.id})}

      organization_user ->
        {:ok, organization_user}
    end
  end
end
