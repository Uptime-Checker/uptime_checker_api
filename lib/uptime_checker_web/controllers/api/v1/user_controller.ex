defmodule UptimeCheckerWeb.Api.V1.UserController do
  use Timex
  use UptimeCheckerWeb, :controller

  alias UptimeChecker.Auth
  alias UptimeChecker.Customer
  alias UptimeChecker.TaskSupervisors
  alias UptimeChecker.Module.Firebase
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
    {:ok, firebase_user} = Firebase.verify_id_token!(params["id_token"])

    with {:ok, user} <- Auth.get_by_email(firebase_user.email),
         {:ok, updated_user} <-
           Customer.update_user_provider(user, %{
             name: firebase_user.name,
             picture_url: firebase_user.picture_url,
             firebase_uid: firebase_user.firebase_uid,
             provider: params["provider"],
             last_login_at: Timex.now()
           }) do
      {:ok, access_token, _claims} = Auth.encode_and_sign(updated_user)

      conn
      |> put_status(:accepted)
      |> json(%{access_token: access_token})
    else
      {:error, %ErrorMessage{code: :not_found} = _e} ->
        updated_params = firebase_user |> Map.put(:provider, params["provider"])

        with {:ok, %User{} = user} <- Customer.create_user_for_provider(updated_params) do
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

  def guest_user(conn, params) do
    with {:ok, %GuestUser{} = guest_user} <- Auth.create_guest_user(params["email"], params["code"]) do
      conn
      |> put_status(:created)
      |> render("show.json", guest_user: guest_user)
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
               firebase_uid: params["firebase_uid"],
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
