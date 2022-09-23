defmodule UptimeCheckerWeb.Api.V1.MonitorController do
  use UptimeCheckerWeb, :controller
  import UptimeChecker.Helper.Util

  alias UptimeChecker.WatchDog
  alias UptimeChecker.Module.Gandalf
  alias UptimeChecker.TaskSupervisors
  alias UptimeChecker.Service.MonitorService
  alias UptimeChecker.Schema.WatchDog.Monitor

  plug UptimeCheckerWeb.Plugs.Org

  action_fallback UptimeCheckerWeb.FallbackController

  def index(conn, _params) do
    monitors = WatchDog.list_monitors()
    render(conn, "index.json", monitors: monitors)
  end

  def create(conn, params) do
    attrs = key_to_atom(params)
    user = current_user(conn)

    with count <- MonitorService.count(user.organization),
         :ok <- Gandalf.can_create_monitor(user, count, attrs.interval),
         {:ok, %Monitor{} = monitor} <- MonitorService.create(attrs, user) do
      Task.Supervisor.start_child(
        {:via, PartitionSupervisor, {TaskSupervisors, self()}},
        WatchDog,
        :create_monitor_regions,
        [monitor],
        restart: :transient
      )

      if Map.has_key?(attrs, :user_ids) do
        Task.Supervisor.start_child(
          {:via, PartitionSupervisor, {TaskSupervisors, self()}},
          WatchDog,
          :create_monitor_users,
          [monitor, attrs.user_ids],
          restart: :transient
        )
      end

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

  def update_order(conn, params) do
    user = current_user(conn)

    with :ok <- Gandalf.can_update_monitor(user),
         {:ok, %Monitor{} = monitor} <- MonitorService.update_order(user, params["id"], params["before_id"]) do
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
