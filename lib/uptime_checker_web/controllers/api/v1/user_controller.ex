defmodule UptimeCheckerWeb.Api.V1.UserController do
  use Timex
  use UptimeCheckerWeb, :controller

  alias UptimeChecker.Auth
  alias UptimeChecker.Cache
  alias UptimeChecker.Payment
  alias UptimeChecker.Customer
  alias UptimeChecker.Authorization
  alias UptimeChecker.Helper.Strings
  alias UptimeChecker.TaskSupervisors
  alias UptimeChecker.Error.ServiceError
  alias UptimeChecker.Schema.Customer.{User, GuestUser}

  action_fallback UptimeCheckerWeb.FallbackController

  def register(conn, params) do
    updated_params = params |> Map.put("name", name_from_email(params["email"]))

    with {:ok, %User{} = user} <- Customer.create_user(updated_params) do
      {:ok, access_token, _claims} = Auth.encode_and_sign(user)

      conn
      |> put_status(:created)
      |> json(%{access_token: access_token})
    end
  end

  def login(conn, %{"email" => email, "password" => password}) do
    with {:ok, %User{} = user} <- Auth.authenticate_user(email, password) do
      {:ok, access_token, _claims} = Auth.encode_and_sign(user)

      conn
      |> put_status(:accepted)
      |> json(%{access_token: access_token})
    end
  end

  def provider_login(conn, params) do
    with {:ok, user} <- Auth.get_by_email(params["email"]),
         {:ok, updated_user} <-
           Customer.update_user_provider(user, %{
             name: params["name"],
             picture_url: params["picture_url"],
             provider_uid: params["provider_uid"],
             provider: params["provider"],
             last_login_at: Timex.now()
           }) do
      {:ok, access_token, _claims} = Auth.encode_and_sign(updated_user)

      conn
      |> put_status(:accepted)
      |> json(%{access_token: access_token})
    else
      {:error, %ErrorMessage{code: :not_found} = _e} ->
        with {:ok, %User{} = user} <- Customer.create_user_for_provider(params) do
          {:ok, access_token, _claims} = Auth.encode_and_sign(user)

          conn
          |> put_status(:created)
          |> json(%{access_token: access_token})
        end
    end
  end

  def me(conn, _params) do
    user = current_user(conn)
    render(conn, "show.json", user: user)
  end

  def full_info(conn, _params) do
    user = current_user(conn)

    cached_organization_users = Cache.User.get_full_info(user.id)

    if is_nil(cached_organization_users) do
      with {:ok, subscription} <- Payment.get_active_subscription_with_plan_features(user.organization_id),
           organization_users <- Authorization.list_organizations_of_user(user) do
        Cache.User.put_full_info(user.id, %{
          user: user,
          subscription: subscription,
          organization_users: organization_users
        })

        render(conn, "full_info.json", %{user: user, subscription: subscription, organization_users: organization_users})
      end
    else
      render(conn, "full_info.json", cached_organization_users)
    end
  end

  def guest_user(conn, params) do
    now = Timex.now()
    rate_limit_in_seconds = 120

    case Auth.get_latest_guest_user(params["email"]) do
      {:ok, guest_user} ->
        diff = Timex.diff(now, guest_user.inserted_at, :second)

        if diff > rate_limit_in_seconds do
          create_guest_user(conn, params)
        else
          {:error,
           ServiceError.guest_user_link_sent_already()
           |> ErrorMessage.bad_request(%{remaining: rate_limit_in_seconds - diff})}
        end

      {:error, %ErrorMessage{code: :not_found} = _e} ->
        create_guest_user(conn, params)
    end
  end

  def create_guest_user(conn, params) do
    code = Strings.random_string(15)

    with {:ok, %GuestUser{} = guest_user} <- Auth.create_guest_user(params["email"], code) do
      conn
      |> put_status(:created)
      |> render("show.json", %{guest_user: guest_user, code: code})
    end
  end

  def get_guest_user(conn, params) do
    with {:ok, %GuestUser{} = guest_user} <- Auth.get_guest_user_by_code(params["code"]) do
      render(conn, "show.json", guest_user: guest_user)
    end
  end

  def email_link_login(conn, params) do
    with {:ok, guest_user} <- Auth.verify_email_link_login(params["email"], params["code"]) do
      with {:ok, user} <- Auth.get_by_email(guest_user.email),
           {:ok, updated_user} <-
             Customer.update_user_provider(user, %{
               provider_uid: params["provider_uid"],
               provider: params["provider"],
               last_login_at: Timex.now()
             }) do
        access_token = after_email_link_login_successful(guest_user, updated_user)

        conn
        |> put_status(:accepted)
        |> json(%{access_token: access_token})
      else
        {:error, %ErrorMessage{code: :not_found} = _e} ->
          with {:ok, %User{} = user} <- Customer.create_user_for_provider(params) do
            access_token = after_email_link_login_successful(guest_user, user)

            conn
            |> put_status(:created)
            |> json(%{access_token: access_token})
          end
      end
    end
  end

  def stripe_customer(conn, _params) do
    user = current_user(conn)

    with {:ok, updated_user} <- UptimeChecker.Module.Stripe.User.create_stripe_customer(user) do
      render(conn, "show.json", user: updated_user)
    end
  end

  def update(conn, params) do
    user = current_user(conn)

    with {:ok, updated_user} <- Customer.update(user, params) do
      Cache.User.bust(user.id)
      render(conn, "show.json", user: updated_user)
    end
  end

  defp after_email_link_login_successful(guest_user, user) do
    Task.Supervisor.start_child(
      {:via, PartitionSupervisor, {TaskSupervisors, self()}},
      Auth,
      :delete_guest_user,
      [guest_user],
      restart: :transient
    )

    {:ok, access_token, _claims} = Auth.encode_and_sign(user)
    access_token
  end
end
