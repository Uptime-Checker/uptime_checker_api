defmodule UptimeCheckerWeb.Api.V1.MonitorController do
  use UptimeCheckerWeb, :controller

  alias UptimeChecker.WatchDog
  alias UptimeChecker.Schema.WatchDog.Monitor

  action_fallback UptimeCheckerWeb.FallbackController

  def index(conn, _params) do
    monitors = WatchDog.list_monitors()
    render(conn, "index.json", monitors: monitors)
  end

  def create(conn, %{"monitor" => monitor_params}) do
    with {:ok, %Monitor{} = monitor} <- WatchDog.create_monitor(monitor_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.monitor_path(conn, :show, monitor))
      |> render("show.json", monitor: monitor)
    end
  end

  def show(conn, %{"id" => id}) do
    monitor = WatchDog.get_monitor!(id)
    render(conn, "show.json", monitor: monitor)
  end

  def update(conn, %{"id" => id, "monitor" => monitor_params}) do
    monitor = WatchDog.get_monitor!(id)

    with {:ok, %Monitor{} = monitor} <- WatchDog.update_monitor(monitor, monitor_params) do
      render(conn, "show.json", monitor: monitor)
    end
  end

  def delete(conn, %{"id" => id}) do
    monitor = WatchDog.get_monitor!(id)

    with {:ok, %Monitor{}} <- WatchDog.delete_monitor(monitor) do
      send_resp(conn, :no_content, "")
    end
  end
end
