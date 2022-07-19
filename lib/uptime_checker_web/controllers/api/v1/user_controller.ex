defmodule UptimeCheckerWeb.Api.V1.UserController do
  use UptimeCheckerWeb, :controller

  alias UptimeChecker.Customer
  alias UptimeChecker.Guardian

  action_fallback UptimeCheckerWeb.FallbackController

  def register(conn, params) do
    updated_params = Map.put(params, "name", name_from_email(params["email"]))

    with {:ok, user} <- Customer.create_user(updated_params) do
      {:ok, access_token, _claims} =
        Guardian.encode_and_sign(user, %{}, token_type: "access", ttl: {180, :day})

      conn
      |> put_status(:created)
      |> json(%{access_token: access_token})
    end
  end

  def login(conn, %{"email" => email, "password" => password}) do
    case Customer.authenticate_user(email, password) do
      {:ok, user} ->
        {:ok, access_token, _claims} =
          Guardian.encode_and_sign(user, %{}, token_type: "access", ttl: {180, :day})

        conn
        |> put_status(:created)
        |> json(%{access_token: access_token})

      {:error, :unauthorized} ->
        conn
        |> send_resp(:unauthorized, Jason.encode!(%{error: "unauthorized"}))
    end
  end

  def me(conn, _params) do
    render(conn, "show.json", user: current_user(conn))
  end
end
