defmodule UptimeChecker.Customer do
  @moduledoc """
  The Customer context.
  """
  import Ecto.Query, warn: false
  alias UptimeChecker.Repo
  alias UptimeChecker.Error.RepoError
  alias UptimeChecker.Schema.Customer.{Organization, User, UserContact}

  def get_organization_by_slug(slug) do
    Organization
    |> Repo.get_by(slug: slug)
    |> case do
      nil -> {:error, RepoError.organization_not_found() |> ErrorMessage.not_found(%{slug: slug})}
      organization -> {:ok, organization}
    end
  end

  def create_organization(attrs \\ %{}, user) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(:organization, Organization.changeset(%Organization{}, attrs))
    |> Ecto.Multi.update(:user, fn %{organization: organization} ->
      Ecto.Changeset.change(user, organization_id: organization.id)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{organization: organization, user: user}} ->
        {:ok, organization, user}

      {:error, _name, changeset, _changes_so_far} ->
        {:error, changeset}
    end
  end

  def list_users do
    Repo.all(User)
  end

  def create_user(attrs \\ %{}) do
    User.registration_changeset(%User{}, attrs)
    |> add_user(false)
  end

  def create_user_for_provider(attrs \\ %{}) do
    User.provider_registration_changeset(%User{}, attrs)
    |> add_user(true)
  end

  defp add_user(changeset, verified) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(:user, changeset)
    |> Ecto.Multi.run(:user_contact, fn _repo, %{user: user} ->
      params = %{email: user.email, mode: :email, verified: verified} |> Map.put(:user, user)

      %UserContact{}
      |> UserContact.changeset(params)
      |> Repo.insert()
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user, user_contact: _user_contact}} ->
        {:ok, user}

      {:error, _name, changeset, _changes_so_far} ->
        {:error, changeset}
    end
  end

  def get_customer_by_id(id) do
    query =
      from user in User,
        left_join: o in assoc(user, :organization),
        where: user.id == ^id,
        preload: [organization: o]

    Repo.one(query)
    |> case do
      nil -> {:error, RepoError.user_not_found() |> ErrorMessage.not_found(%{id: id})}
      user -> {:ok, user}
    end
  end

  def update_user_provider(%User{} = user, attrs) do
    user
    |> User.update_provider_changeset(attrs)
    |> Repo.update()
  end

  def get_user_contact_by_id(id) do
    UserContact
    |> Repo.get(id)
    |> case do
      nil -> {:error, RepoError.user_contact_not_found() |> ErrorMessage.not_found(%{id: id})}
      user_contact -> {:ok, user_contact}
    end
  end
end
