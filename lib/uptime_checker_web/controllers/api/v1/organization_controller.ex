defmodule UptimeCheckerWeb.Api.V1.OrganizationController do
  use UptimeCheckerWeb, :controller

  alias UptimeChecker.Customer
  alias UptimeChecker.Schema.Customer.Organization

  action_fallback UptimeCheckerWeb.FallbackController

  def create(conn, params) do
    user = current_user(conn)

    with {:ok, %Organization{} = organization} <- Customer.create_organization(params, user) do
      conn
      |> put_status(:created)
      |> render("show.json", organization: organization)
    end
  end
end
