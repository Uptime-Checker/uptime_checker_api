defmodule UptimeChecker.Customer do
  @moduledoc """
  The Customer context.
  """
  import Ecto.Query, warn: false
  alias UptimeChecker.Repo
  alias UptimeChecker.Schema.Customer.{Organization, User, UserContact, GuestUser}

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

  def update_user_provider(%User{} = user, attrs) do
    user
    |> User.update_provider_changeset(attrs)
    |> Repo.update()
  end

  def get_user_contact_by_id(id) do
    UserContact
    |> Repo.get(id)
  end

  def create_guest_user(email, code) do
    now = Timex.now()
    attrs = %{email: email, code: code, expires_at: Timex.shift(now, minutes: +10)}

    %GuestUser{}
    |> GuestUser.changeset(attrs)
    |> Repo.insert()
  end

  def get_guest_user_by_code(code) do
    GuestUser
    |> Repo.get_by(code: code)
  end

  def list_guest_users do
    Repo.all(GuestUser)
  end

  def delete_guest_user(%GuestUser{} = guest_user) do
    Repo.delete(guest_user)
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
