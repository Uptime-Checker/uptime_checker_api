defmodule UptimeCheckerWeb.Api.V1.UserController do
  use UptimeCheckerWeb, :controller

  alias UptimeChecker.Customer
  alias UptimeChecker.Guardian
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
    with {:ok, firebase_user} <- UptimeChecker.Module.Firebase.verify_id_token!(params["id_token"]) do
      conn
      |> put_status(:ok)
      |> json(firebase_user)
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
