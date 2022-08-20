defmodule UptimeChecker.Auth do
  use Timex

  import Ecto.Query, warn: false
  alias UptimeChecker.Repo
  alias UptimeChecker.Schema.Customer.{User, GuestUser}

  def get_by_email(email) do
    query = from u in User, where: u.email == ^email

    case Repo.one(query) do
      nil -> {:error, :not_found}
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

  def verify_email_link_login(email, code) do
    now = Timex.now()

    GuestUser
    |> Repo.get_by(code: code)
    |> case do
      nil ->
        {:error, :not_found}

      guest_user ->
        cond do
          guest_user.email != email ->
            {:error, :email_mismatch}

          Timex.after?(now, guest_user.expires_at) ->
            {:error, :code_expired}

          true ->
            {:ok, guest_user}
        end
    end
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
end
