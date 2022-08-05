defmodule UptimeChecker.Customer do
  @moduledoc """
  The Customer context.
  """
  import Ecto.Query, warn: false
  alias UptimeChecker.Repo
  alias UptimeChecker.Schema.Customer.{Organization, User, UserContact}

  def get_organization(id), do: Repo.get(Organization, id)

  def get_organization_by_slug(slug) do
    Organization |> Repo.get_by(slug: slug)
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
    Ecto.Multi.new()
    |> Ecto.Multi.insert(:user, User.registration_changeset(%User{}, attrs))
    |> Ecto.Multi.run(:user_contact, fn _repo, %{user: user} ->
      params = %{email: user.email, mode: :email} |> Map.put(:user, user)

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

  def get_by_email(email) do
    query = from u in User, where: u.email == ^email

    case Repo.one(query) do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end

  def get_by_id(id) do
    User
    |> Repo.get(id)
    |> Repo.preload([:organization])
  end

  def get_user_contact_by_id(id) do
    UserContact
    |> Repo.get(id)
  end

  def authenticate_user(email, password) do
    with {:ok, user} <- get_by_email(email) do
      case validate_password(password, user.password) do
        false -> {:error, :unauthorized}
        true -> {:ok, user}
      end
    end
  end

  defp validate_password(password, encrypted_password) do
    Bcrypt.verify_pass(password, encrypted_password)
  end
end
