defmodule UptimeCheckerWeb.Api.V1.OrganizationController do
  use UptimeCheckerWeb, :controller

  alias UptimeChecker.Customer
  alias UptimeChecker.Customer.Organization

  action_fallback UptimeCheckerWeb.FallbackControlle

  def create(conn, params) do
    user = current_user(conn)

    with {:ok, %Organization{} = organization, _user} <- Customer.create_organization(params, user) do
      conn
      |> put_status(:created)
      |> render("show.json", organization: organization)
    end
  end
end
