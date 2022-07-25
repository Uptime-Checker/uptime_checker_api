defmodule UptimeCheckerWeb.Api.V1.CheckController do
  use UptimeCheckerWeb, :controller

  alias UptimeChecker.WatchDog
  alias UptimeChecker.Schema.WatchDog.Check

  action_fallback UptimeCheckerWeb.FallbackController

  def index(conn, _params) do
    checks = WatchDog.list_checks()
    render(conn, "index.json", checks: checks)
  end

  def create(conn, %{"check" => check_params}) do
    with {:ok, %Check{} = check} <- WatchDog.create_check(check_params) do
      conn
      |> put_status(:created)
      |> render("show.json", check: check)
    end
  end

  def show(conn, %{"id" => id}) do
    check = WatchDog.get_check!(id)
    render(conn, "show.json", check: check)
  end

  def update(conn, %{"id" => id, "check" => check_params}) do
    check = WatchDog.get_check!(id)

    with {:ok, %Check{} = check} <- WatchDog.update_check(check, check_params) do
      render(conn, "show.json", check: check)
    end
  end

  def delete(conn, %{"id" => id}) do
    check = WatchDog.get_check!(id)

    with {:ok, %Check{}} <- WatchDog.delete_check(check) do
      send_resp(conn, :no_content, "")
    end
  end
end
