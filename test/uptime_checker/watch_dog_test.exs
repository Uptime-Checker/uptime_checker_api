defmodule UptimeChecker.WatchDogTest do
  use UptimeChecker.DataCase

  alias UptimeChecker.WatchDog

  describe "monitors" do
    alias UptimeChecker.WatchDog.Monitor

    import UptimeChecker.WatchDogFixtures

    @invalid_attrs %{body: nil, contains: nil, interval: nil, last_checked_at: nil, last_failed_at: nil, method: nil, name: nil, resolve_threshold: nil, state: nil, status_codes: nil, timeout: nil, url: nil}

    test "list_monitors/0 returns all monitors" do
      monitor = monitor_fixture()
      assert WatchDog.list_monitors() == [monitor]
    end

    test "get_monitor!/1 returns the monitor with given id" do
      monitor = monitor_fixture()
      assert WatchDog.get_monitor!(monitor.id) == monitor
    end

    test "create_monitor/1 with valid data creates a monitor" do
      valid_attrs = %{body: "some body", contains: "some contains", interval: 42, last_checked_at: ~U[2022-07-19 11:54:00Z], last_failed_at: ~U[2022-07-19 11:54:00Z], method: 42, name: "some name", resolve_threshold: 42, state: 42, status_codes: [], timeout: 42, url: "some url"}

      assert {:ok, %Monitor{} = monitor} = WatchDog.create_monitor(valid_attrs)
      assert monitor.body == "some body"
      assert monitor.contains == "some contains"
      assert monitor.interval == 42
      assert monitor.last_checked_at == ~U[2022-07-19 11:54:00Z]
      assert monitor.last_failed_at == ~U[2022-07-19 11:54:00Z]
      assert monitor.method == 42
      assert monitor.name == "some name"
      assert monitor.resolve_threshold == 42
      assert monitor.state == 42
      assert monitor.status_codes == []
      assert monitor.timeout == 42
      assert monitor.url == "some url"
    end

    test "create_monitor/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = WatchDog.create_monitor(@invalid_attrs)
    end

    test "update_monitor/2 with valid data updates the monitor" do
      monitor = monitor_fixture()
      update_attrs = %{body: "some updated body", contains: "some updated contains", interval: 43, last_checked_at: ~U[2022-07-20 11:54:00Z], last_failed_at: ~U[2022-07-20 11:54:00Z], method: 43, name: "some updated name", resolve_threshold: 43, state: 43, status_codes: [], timeout: 43, url: "some updated url"}

      assert {:ok, %Monitor{} = monitor} = WatchDog.update_monitor(monitor, update_attrs)
      assert monitor.body == "some updated body"
      assert monitor.contains == "some updated contains"
      assert monitor.interval == 43
      assert monitor.last_checked_at == ~U[2022-07-20 11:54:00Z]
      assert monitor.last_failed_at == ~U[2022-07-20 11:54:00Z]
      assert monitor.method == 43
      assert monitor.name == "some updated name"
      assert monitor.resolve_threshold == 43
      assert monitor.state == 43
      assert monitor.status_codes == []
      assert monitor.timeout == 43
      assert monitor.url == "some updated url"
    end

    test "update_monitor/2 with invalid data returns error changeset" do
      monitor = monitor_fixture()
      assert {:error, %Ecto.Changeset{}} = WatchDog.update_monitor(monitor, @invalid_attrs)
      assert monitor == WatchDog.get_monitor!(monitor.id)
    end

    test "delete_monitor/1 deletes the monitor" do
      monitor = monitor_fixture()
      assert {:ok, %Monitor{}} = WatchDog.delete_monitor(monitor)
      assert_raise Ecto.NoResultsError, fn -> WatchDog.get_monitor!(monitor.id) end
    end

    test "change_monitor/1 returns a monitor changeset" do
      monitor = monitor_fixture()
      assert %Ecto.Changeset{} = WatchDog.change_monitor(monitor)
    end
  end
end
