defmodule UptimeCheckerWeb.Api.V1.Auth.MonitorController do
  use UptimeCheckerWeb, :controller

  alias UptimeChecker.WatchDog
  alias UptimeChecker.Schema.WatchDog.Monitor

  action_fallback UptimeCheckerWeb.FallbackController

  def index(conn, _params) do
    monitors = WatchDog.list_monitors()
    render(conn, "index.json", monitors: monitors)
  end

  def create(conn, params) do
    with {:ok, %Monitor{} = monitor} <- WatchDog.create_monitor(params, current_user(conn)) do
      conn
      |> put_status(:created)
      |> render("show.json", monitor: monitor)
    end
  end

  def show(conn, %{"id" => id}) do
    monitor = WatchDog.get_monitor(id)
    render(conn, "show.json", monitor: monitor)
  end

  def update(conn, %{"id" => id, "monitor" => monitor_params}) do
    monitor = WatchDog.get_monitor(id)

    with {:ok, %Monitor{} = monitor} <- WatchDog.update_monitor(monitor, monitor_params) do
      render(conn, "show.json", monitor: monitor)
    end
  end

  def delete(conn, %{"id" => id}) do
    monitor = WatchDog.get_monitor(id)

    with {:ok, %Monitor{}} <- WatchDog.delete_monitor(monitor) do
      send_resp(conn, :no_content, "")
    end
  end
end
