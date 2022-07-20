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

  describe "regions" do
    alias UptimeChecker.WatchDog.Region

    import UptimeChecker.WatchDogFixtures

    @invalid_attrs %{ip_address: nil, key: nil, name: nil}

    test "list_regions/0 returns all regions" do
      region = region_fixture()
      assert WatchDog.list_regions() == [region]
    end

    test "get_region!/1 returns the region with given id" do
      region = region_fixture()
      assert WatchDog.get_region!(region.id) == region
    end

    test "create_region/1 with valid data creates a region" do
      valid_attrs = %{ip_address: "some ip_address", key: "some key", name: "some name"}

      assert {:ok, %Region{} = region} = WatchDog.create_region(valid_attrs)
      assert region.ip_address == "some ip_address"
      assert region.key == "some key"
      assert region.name == "some name"
    end

    test "create_region/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = WatchDog.create_region(@invalid_attrs)
    end

    test "update_region/2 with valid data updates the region" do
      region = region_fixture()
      update_attrs = %{ip_address: "some updated ip_address", key: "some updated key", name: "some updated name"}

      assert {:ok, %Region{} = region} = WatchDog.update_region(region, update_attrs)
      assert region.ip_address == "some updated ip_address"
      assert region.key == "some updated key"
      assert region.name == "some updated name"
    end

    test "update_region/2 with invalid data returns error changeset" do
      region = region_fixture()
      assert {:error, %Ecto.Changeset{}} = WatchDog.update_region(region, @invalid_attrs)
      assert region == WatchDog.get_region!(region.id)
    end

    test "delete_region/1 deletes the region" do
      region = region_fixture()
      assert {:ok, %Region{}} = WatchDog.delete_region(region)
      assert_raise Ecto.NoResultsError, fn -> WatchDog.get_region!(region.id) end
    end

    test "change_region/1 returns a region changeset" do
      region = region_fixture()
      assert %Ecto.Changeset{} = WatchDog.change_region(region)
    end
  end

  describe "checks" do
    alias UptimeChecker.WatchDog.Check

    import UptimeChecker.WatchDogFixtures

    @invalid_attrs %{duration: nil, success: nil}

    test "list_checks/0 returns all checks" do
      check = check_fixture()
      assert WatchDog.list_checks() == [check]
    end

    test "get_check!/1 returns the check with given id" do
      check = check_fixture()
      assert WatchDog.get_check!(check.id) == check
    end

    test "create_check/1 with valid data creates a check" do
      valid_attrs = %{duration: 120.5, success: true}

      assert {:ok, %Check{} = check} = WatchDog.create_check(valid_attrs)
      assert check.duration == 120.5
      assert check.success == true
    end

    test "create_check/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = WatchDog.create_check(@invalid_attrs)
    end

    test "update_check/2 with valid data updates the check" do
      check = check_fixture()
      update_attrs = %{duration: 456.7, success: false}

      assert {:ok, %Check{} = check} = WatchDog.update_check(check, update_attrs)
      assert check.duration == 456.7
      assert check.success == false
    end

    test "update_check/2 with invalid data returns error changeset" do
      check = check_fixture()
      assert {:error, %Ecto.Changeset{}} = WatchDog.update_check(check, @invalid_attrs)
      assert check == WatchDog.get_check!(check.id)
    end

    test "delete_check/1 deletes the check" do
      check = check_fixture()
      assert {:ok, %Check{}} = WatchDog.delete_check(check)
      assert_raise Ecto.NoResultsError, fn -> WatchDog.get_check!(check.id) end
    end

    test "change_check/1 returns a check changeset" do
      check = check_fixture()
      assert %Ecto.Changeset{} = WatchDog.change_check(check)
    end
  end
end
