defmodule UptimeChecker.Auth do
  use Timex

  import Ecto.Query, warn: false

  alias UptimeChecker.Repo
  alias UptimeChecker.Guardian
  alias UptimeChecker.Helper.Strings
  alias UptimeChecker.Error.{RepoError, ServiceError}
  alias UptimeChecker.Schema.Customer.{User, GuestUser}

  def get_by_email(email) do
    query = from u in User, where: u.email == ^email

    case Repo.one(query) do
      nil -> {:error, RepoError.user_not_found() |> ErrorMessage.not_found(%{email: email})}
      user -> {:ok, user}
    end
  end

  def get_by_email_with_org(email) do
    query =
      from user in User,
        left_join: o in assoc(user, :organization),
        where: user.email == ^email,
        preload: [organization: o]

    Repo.one(query)
    |> case do
      nil -> {:error, RepoError.user_not_found() |> ErrorMessage.not_found(%{email: email})}
      user -> {:ok, user}
    end
  end

  def get_by_email_with_org_and_role(email) do
    query =
      from user in User,
        left_join: r in assoc(user, :role),
        left_join: o in assoc(user, :organization),
        where: user.email == ^email,
        preload: [organization: o, role: r]

    Repo.one(query)
    |> case do
      nil -> {:error, RepoError.user_not_found() |> ErrorMessage.not_found(%{email: email})}
      user -> {:ok, user}
    end
  end

  def authenticate_user(email, password) do
    with {:ok, user} <- get_by_email(email) do
      case validate_password(password, user.password) do
        false -> {:error, ServiceError.unauthorized() |> ErrorMessage.unauthorized(%{email: email})}
        true -> {:ok, user}
      end
    end
  end

  defp validate_password(password, encrypted_password) do
    Bcrypt.verify_pass(password, encrypted_password)
  end

  def verify_email_link_login(email, code) do
    now = Timex.now()

    GuestUser
    |> Repo.get_by(code: Strings.hash_string(code))
    |> case do
      nil ->
        {:error, RepoError.guest_user_not_found() |> ErrorMessage.forbidden(%{code: code})}

      guest_user ->
        cond do
          guest_user.email != email ->
            {:error, ServiceError.email_mismatch() |> ErrorMessage.forbidden(%{email: email})}

          Timex.after?(now, guest_user.expires_at) ->
            {:error, ServiceError.code_expired() |> ErrorMessage.bad_request(%{code: code})}

          true ->
            {:ok, guest_user}
        end
    end
  end

  def create_guest_user(email, code) do
    now = Timex.now()
    attrs = %{email: email, code: Strings.hash_string(code), expires_at: Timex.shift(now, minutes: +10)}

    %GuestUser{}
    |> GuestUser.changeset(attrs)
    |> Repo.insert()
  end

  def get_guest_user_by_code(code) do
    GuestUser
    |> Repo.get_by(code: Strings.hash_string(code))
    |> case do
      nil -> {:error, RepoError.guest_user_not_found() |> ErrorMessage.not_found(%{code: code})}
      guest_user -> {:ok, guest_user}
    end
  end

  def list_guest_users do
    Repo.all(GuestUser)
  end

  def delete_guest_user(%GuestUser{} = guest_user) do
    Repo.delete(guest_user)
  end

  def encode_and_sign(user) do
    Guardian.encode_and_sign(user, %{}, token_type: "access", ttl: {180, :day})
  end
end
