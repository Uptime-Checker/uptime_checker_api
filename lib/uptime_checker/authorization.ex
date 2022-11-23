defmodule UptimeChecker.Authorization do
  require Logger
  import Ecto.Query, warn: false

  alias UptimeChecker.Repo
  alias UptimeChecker.Error.RepoError
  alias UptimeChecker.Schema.Customer.{User, Role, OrganizationUser, Claim, RoleClaim}

  def create_role(attrs \\ %{}) do
    %Role{}
    |> Role.changeset(attrs)
    |> Repo.insert()
  end

  def create_claim(attrs \\ %{}) do
    %Claim{}
    |> Claim.changeset(attrs)
    |> Repo.insert()
  end

  def create_role_claim(attrs) do
    %RoleClaim{}
    |> RoleClaim.changeset(attrs)
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

  def update_default_organization_role(user, organization, role) do
    user
    |> User.update_organization_role_changeset(%{organization: organization, role: role})
    |> Repo.update()
  end

  def create_organization_user(user, organization, role) do
    attrs = %{organization: organization, role: role}
    params = attrs |> Map.put(:user, user)

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:organization_user, OrganizationUser.changeset(%OrganizationUser{}, params))
    |> Ecto.Multi.update(:user, User.update_organization_role_changeset(user, attrs))
    |> Repo.transaction()
    |> case do
      {:ok, %{organization_user: organization_user, user: user}} ->
        {:ok, organization_user, user}

      {:error, name, changeset, _changes_so_far} ->
        Logger.error("Failed to create organization_user for user #{user.id}, error: #{inspect(changeset.errors)}")
        {:error, name, changeset}
    end
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

  def count_users_in_organization(organization) do
    query =
      from organization_user in OrganizationUser,
        where: organization_user.organization_id == ^organization.id,
        select: count(organization_user.id)

    Repo.one(query)
  end
end
