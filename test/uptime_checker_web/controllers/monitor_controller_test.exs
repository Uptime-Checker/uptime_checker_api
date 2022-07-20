defmodule UptimeCheckerWeb.MonitorControllerTest do
  use UptimeCheckerWeb.ConnCase

  import UptimeChecker.WatchDogFixtures

  alias UptimeChecker.WatchDog.Monitor

  @create_attrs %{
    body: "some body",
    contains: "some contains",
    interval: 42,
    last_checked_at: ~U[2022-07-19 11:54:00Z],
    last_failed_at: ~U[2022-07-19 11:54:00Z],
    method: 42,
    name: "some name",
    resolve_threshold: 42,
    state: 42,
    status_codes: [],
    timeout: 42,
    url: "some url"
  }
  @update_attrs %{
    body: "some updated body",
    contains: "some updated contains",
    interval: 43,
    last_checked_at: ~U[2022-07-20 11:54:00Z],
    last_failed_at: ~U[2022-07-20 11:54:00Z],
    method: 43,
    name: "some updated name",
    resolve_threshold: 43,
    state: 43,
    status_codes: [],
    timeout: 43,
    url: "some updated url"
  }
  @invalid_attrs %{body: nil, contains: nil, interval: nil, last_checked_at: nil, last_failed_at: nil, method: nil, name: nil, resolve_threshold: nil, state: nil, status_codes: nil, timeout: nil, url: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all monitors", %{conn: conn} do
      conn = get(conn, Routes.monitor_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create monitor" do
    test "renders monitor when data is valid", %{conn: conn} do
      conn = post(conn, Routes.monitor_path(conn, :create), monitor: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.monitor_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "body" => "some body",
               "contains" => "some contains",
               "interval" => 42,
               "last_checked_at" => "2022-07-19T11:54:00Z",
               "last_failed_at" => "2022-07-19T11:54:00Z",
               "method" => 42,
               "name" => "some name",
               "resolve_threshold" => 42,
               "state" => 42,
               "status_codes" => [],
               "timeout" => 42,
               "url" => "some url"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.monitor_path(conn, :create), monitor: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update monitor" do
    setup [:create_monitor]

    test "renders monitor when data is valid", %{conn: conn, monitor: %Monitor{id: id} = monitor} do
      conn = put(conn, Routes.monitor_path(conn, :update, monitor), monitor: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.monitor_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "body" => "some updated body",
               "contains" => "some updated contains",
               "interval" => 43,
               "last_checked_at" => "2022-07-20T11:54:00Z",
               "last_failed_at" => "2022-07-20T11:54:00Z",
               "method" => 43,
               "name" => "some updated name",
               "resolve_threshold" => 43,
               "state" => 43,
               "status_codes" => [],
               "timeout" => 43,
               "url" => "some updated url"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, monitor: monitor} do
      conn = put(conn, Routes.monitor_path(conn, :update, monitor), monitor: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete monitor" do
    setup [:create_monitor]

    test "deletes chosen monitor", %{conn: conn, monitor: monitor} do
      conn = delete(conn, Routes.monitor_path(conn, :delete, monitor))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.monitor_path(conn, :show, monitor))
      end
    end
  end

  defp create_monitor(_) do
    monitor = monitor_fixture()
    %{monitor: monitor}
  end
end
