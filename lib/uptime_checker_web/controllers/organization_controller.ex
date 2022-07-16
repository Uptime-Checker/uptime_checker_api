defmodule UptimeCheckerWeb.OrganizationController do
  use UptimeCheckerWeb, :controller

  alias UptimeChecker.Customer
  alias UptimeChecker.Customer.Organization

  action_fallback UptimeCheckerWeb.FallbackController

  def index(conn, _params) do
    organizations = Customer.list_organizations()
    render(conn, "index.json", organizations: organizations)
  end

  def create(conn, %{"organization" => organization_params}) do
    with {:ok, %Organization{} = organization} <- Customer.create_organization(organization_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.organization_path(conn, :show, organization))
      |> render("show.json", organization: organization)
    end
  end

  def show(conn, %{"id" => id}) do
    organization = Customer.get_organization!(id)
    render(conn, "show.json", organization: organization)
  end

  def update(conn, %{"id" => id, "organization" => organization_params}) do
    organization = Customer.get_organization!(id)

    with {:ok, %Organization{} = organization} <- Customer.update_organization(organization, organization_params) do
      render(conn, "show.json", organization: organization)
    end
  end

  def delete(conn, %{"id" => id}) do
    organization = Customer.get_organization!(id)

    with {:ok, %Organization{}} <- Customer.delete_organization(organization) do
      send_resp(conn, :no_content, "")
    end
  end
end
