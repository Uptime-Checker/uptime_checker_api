defmodule UptimeCheckerWeb.Api.V1.RoleController do
  use UptimeCheckerWeb, :controller

  alias UptimeChecker.Cache
  alias UptimeChecker.Authorization

  action_fallback UptimeCheckerWeb.FallbackController

  def index(conn, _params) do
    cached_roles = Cache.User.get_roles()

    if is_nil(cached_roles) do
      roles = Authorization.list_roles()
      Cache.User.put_roles(roles)
      render(conn, "index.json", roles: roles)
    else
      render(conn, "index.json", roles: cached_roles)
    end
  end
end
