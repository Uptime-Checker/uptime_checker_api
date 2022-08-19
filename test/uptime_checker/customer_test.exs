defmodule UptimeChecker.CustomerTest do
  use UptimeChecker.DataCase

  alias UptimeChecker.Customer

  describe "organizations" do
    alias UptimeChecker.Customer.Organization

    import UptimeChecker.CustomerFixtures

    @invalid_attrs %{key: nil, name: nil}

    test "list_organizations/0 returns all organizations" do
      organization = organization_fixture()
      assert Customer.list_organizations() == [organization]
    end

    test "get_organization!/1 returns the organization with given id" do
      organization = organization_fixture()
      assert Customer.get_organization!(organization.id) == organization
    end

    test "create_organization/1 with valid data creates a organization" do
      valid_attrs = %{key: "some key", name: "some name"}

      assert {:ok, %Organization{} = organization} = Customer.create_organization(valid_attrs)
      assert organization.key == "some key"
      assert organization.name == "some name"
    end

    test "create_organization/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Customer.create_organization(@invalid_attrs)
    end

    test "update_organization/2 with valid data updates the organization" do
      organization = organization_fixture()
      update_attrs = %{key: "some updated key", name: "some updated name"}

      assert {:ok, %Organization{} = organization} = Customer.update_organization(organization, update_attrs)
      assert organization.key == "some updated key"
      assert organization.name == "some updated name"
    end

    test "update_organization/2 with invalid data returns error changeset" do
      organization = organization_fixture()
      assert {:error, %Ecto.Changeset{}} = Customer.update_organization(organization, @invalid_attrs)
      assert organization == Customer.get_organization!(organization.id)
    end

    test "delete_organization/1 deletes the organization" do
      organization = organization_fixture()
      assert {:ok, %Organization{}} = Customer.delete_organization(organization)
      assert_raise Ecto.NoResultsError, fn -> Customer.get_organization!(organization.id) end
    end

    test "change_organization/1 returns a organization changeset" do
      organization = organization_fixture()
      assert %Ecto.Changeset{} = Customer.change_organization(organization)
    end
  end

  describe "users" do
    alias UptimeChecker.Customer.User

    import UptimeChecker.CustomerFixtures

    @invalid_attrs %{email: nil, firebase_uid: nil, name: nil, password_hash: nil, provider: nil}

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Customer.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Customer.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      valid_attrs = %{
        email: "some email",
        firebase_uid: "some firebase_uid",
        name: "some name",
        password_hash: "some password_hash",
        provider: 42
      }

      assert {:ok, %User{} = user} = Customer.create_user(valid_attrs)
      assert user.email == "some email"
      assert user.firebase_uid == "some firebase_uid"
      assert user.name == "some name"
      assert user.password_hash == "some password_hash"
      assert user.provider == 42
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Customer.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()

      update_attrs = %{
        email: "some updated email",
        firebase_uid: "some updated firebase_uid",
        name: "some updated name",
        password_hash: "some updated password_hash",
        provider: 43
      }

      assert {:ok, %User{} = user} = Customer.update_user(user, update_attrs)
      assert user.email == "some updated email"
      assert user.firebase_uid == "some updated firebase_uid"
      assert user.name == "some updated name"
      assert user.password_hash == "some updated password_hash"
      assert user.provider == 43
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Customer.update_user(user, @invalid_attrs)
      assert user == Customer.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Customer.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Customer.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Customer.change_user(user)
    end
  end
end
