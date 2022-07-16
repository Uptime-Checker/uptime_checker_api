defmodule UptimeCheckerWeb.UserControllerTest do
  use UptimeCheckerWeb.ConnCase

  import UptimeChecker.CustomerFixtures

  alias UptimeChecker.Customer.User

  @create_attrs %{
    email: "some email",
    firebase_uid: "some firebase_uid",
    name: "some name",
    password_hash: "some password_hash",
    provider: 42
  }
  @update_attrs %{
    email: "some updated email",
    firebase_uid: "some updated firebase_uid",
    name: "some updated name",
    password_hash: "some updated password_hash",
    provider: 43
  }
  @invalid_attrs %{email: nil, firebase_uid: nil, name: nil, password_hash: nil, provider: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all users", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create user" do
    test "renders user when data is valid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.user_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "email" => "some email",
               "firebase_uid" => "some firebase_uid",
               "name" => "some name",
               "password_hash" => "some password_hash",
               "provider" => 42
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update user" do
    setup [:create_user]

    test "renders user when data is valid", %{conn: conn, user: %User{id: id} = user} do
      conn = put(conn, Routes.user_path(conn, :update, user), user: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.user_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "email" => "some updated email",
               "firebase_uid" => "some updated firebase_uid",
               "name" => "some updated name",
               "password_hash" => "some updated password_hash",
               "provider" => 43
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = put(conn, Routes.user_path(conn, :update, user), user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete user" do
    setup [:create_user]

    test "deletes chosen user", %{conn: conn, user: user} do
      conn = delete(conn, Routes.user_path(conn, :delete, user))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.user_path(conn, :show, user))
      end
    end
  end

  defp create_user(_) do
    user = user_fixture()
    %{user: user}
  end
end
