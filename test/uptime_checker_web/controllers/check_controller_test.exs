defmodule UptimeCheckerWeb.CheckControllerTest do
  use UptimeCheckerWeb.ConnCase

  import UptimeChecker.WatchDogFixtures

  alias UptimeChecker.WatchDog.Check

  @create_attrs %{
    duration: 120.5,
    success: true
  }
  @update_attrs %{
    duration: 456.7,
    success: false
  }
  @invalid_attrs %{duration: nil, success: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all checks", %{conn: conn} do
      conn = get(conn, Routes.check_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create check" do
    test "renders check when data is valid", %{conn: conn} do
      conn = post(conn, Routes.check_path(conn, :create), check: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.check_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "duration" => 120.5,
               "success" => true
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.check_path(conn, :create), check: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update check" do
    setup [:create_check]

    test "renders check when data is valid", %{conn: conn, check: %Check{id: id} = check} do
      conn = put(conn, Routes.check_path(conn, :update, check), check: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.check_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "duration" => 456.7,
               "success" => false
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, check: check} do
      conn = put(conn, Routes.check_path(conn, :update, check), check: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete check" do
    setup [:create_check]

    test "deletes chosen check", %{conn: conn, check: check} do
      conn = delete(conn, Routes.check_path(conn, :delete, check))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.check_path(conn, :show, check))
      end
    end
  end

  defp create_check(_) do
    check = check_fixture()
    %{check: check}
  end
end
