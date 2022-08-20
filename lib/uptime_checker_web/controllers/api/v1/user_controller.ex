defmodule UptimeCheckerWeb.Api.V1.UserController do
  use UptimeCheckerWeb, :controller

  alias UptimeChecker.Customer
  alias UptimeChecker.Guardian
  alias UptimeChecker.Module.Firebase
  alias UptimeChecker.Schema.Customer.User

  action_fallback UptimeCheckerWeb.FallbackController

  def register(conn, params) do
    updated_params = params |> Map.put("name", name_from_email(params["email"]))

    with {:ok, %User{} = user} <- Customer.create_user(updated_params) do
      {:ok, access_token, _claims} = encode_and_sign(user)

      conn
      |> put_status(:created)
      |> json(%{access_token: access_token})
    end
  end

  def login(conn, %{"email" => email, "password" => password}) do
    case Customer.authenticate_user(email, password) do
      {:ok, user} ->
        {:ok, access_token, _claims} = encode_and_sign(user)

        conn
        |> put_status(:created)
        |> json(%{access_token: access_token})

      {:error, :unauthorized} ->
        conn
        |> send_resp(:unauthorized, Jason.encode!(%{error: "unauthorized"}))
    end
  end

  def provider_login(conn, params) do
    {:ok, firebase_user} = Firebase.verify_id_token!(params["id_token"])

    with {:ok, user} <- Customer.get_by_email(firebase_user.email),
         {:ok, updated_user} <-
           Customer.update_user_provider(user, %{
             name: firebase_user.name,
             picture_url: firebase_user.picture_url,
             firebase_uid: firebase_user.firebase_uid
           }) do
      {:ok, access_token, _claims} = encode_and_sign(updated_user)

      conn
      |> put_status(:accepted)
      |> json(%{access_token: access_token})
    else
      {:error, :not_found} ->
        updated_params = firebase_user |> Map.put(:provider, params["provider"])

        with {:ok, %User{} = user} <- Customer.create_user_for_provider(updated_params) do
          {:ok, access_token, _claims} = encode_and_sign(user)

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

  defp encode_and_sign(user) do
    Guardian.encode_and_sign(user, %{}, token_type: "access", ttl: {180, :day})
  end
end
