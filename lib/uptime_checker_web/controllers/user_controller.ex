defmodule UptimeCheckerWeb.UserController do
  use UptimeCheckerWeb, :controller

  alias UptimeChecker.Customer
  alias UptimeChecker.Customer.User

  action_fallback UptimeCheckerWeb.FallbackController

  def index(conn, _params) do
    users = Customer.list_users()
    render(conn, "index.json", users: users)
  end

  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Customer.create_user(user_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.user_path(conn, :show, user))
      |> render("show.json", user: user)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Customer.get_user!(id)
    render(conn, "show.json", user: user)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Customer.get_user!(id)

    with {:ok, %User{} = user} <- Customer.update_user(user, user_params) do
      render(conn, "show.json", user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Customer.get_user!(id)

    with {:ok, %User{}} <- Customer.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end
end
