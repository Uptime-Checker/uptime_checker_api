defmodule UptimeCheckerWeb.Api.V1.RoleController do
  use UptimeCheckerWeb, :controller

  alias UptimeChecker.Authorization

  action_fallback UptimeCheckerWeb.FallbackController

  def index(conn, _params) do
    roles = Authorization.list_roles()
    render(conn, "index.json", roles: roles)
  end
end
