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

  def index(conn, params) do
    user = current_user(conn)

    monitors = MonitorService.list(user.organization, params["offset"])
    render(conn, "index.json", %{monitors: monitors})
  end

  def create(conn, params) do
    attrs = key_to_atom(params)
    user = current_user(conn)

    with count <- MonitorService.count(user.organization),
         :ok <- Gandalf.can_create_monitor(user, count, attrs.interval),
         {:ok, %Monitor{} = monitor} <- MonitorService.create(attrs, user) do
      Task.Supervisor.start_child(
        {:via, PartitionSupervisor, {TaskSupervisors, self()}},
        fn ->
          WatchDog.create_monitor_regions(monitor)
        end,
        restart: :transient
      )

      Task.Supervisor.start_child(
        {:via, PartitionSupervisor, {TaskSupervisors, self()}},
        fn ->
          WatchDog.create_monitor_status_change(:pending, monitor)
        end,
        restart: :transient
      )

      if Map.has_key?(attrs, :user_ids) do
        Task.Supervisor.start_child(
          {:via, PartitionSupervisor, {TaskSupervisors, self()}},
          fn ->
            WatchDog.create_monitor_users(monitor, attrs.user_ids)
          end,
          restart: :transient
        )
      end

      conn
      |> put_status(:created)
      |> render("show.json", monitor: monitor)
    end
  end

  def show(conn, %{"id" => id}) do
    monitor = MonitorService.get(id)
    render(conn, "show.json", monitor: monitor)
  end

  def update(conn, %{"id" => id, "monitor" => monitor_params}) do
    monitor = MonitorService.get(id)

    with {:ok, %Monitor{} = monitor} <- WatchDog.update_monitor(monitor, monitor_params) do
      render(conn, "show.json", monitor: monitor)
    end
  end

  def update_order(conn, params) do
    user = current_user(conn)

    with :ok <- Gandalf.can_update_resource(user),
         {:ok, %Monitor{} = monitor} <- MonitorService.update_order(params["id"], params["before_id"], user) do
      render(conn, "show.json", monitor: monitor)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = current_user(conn)

    with :ok <- Gandalf.can_delete_resource(user),
         {:ok, %Monitor{} = monitor} <- MonitorService.delete(id, user) do
      render(conn, "show.json", monitor: monitor)
    end
  end
end
