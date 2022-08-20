defmodule UptimeCheckerWeb.Api.V1.RoleView do
  use UptimeCheckerWeb, :view
  alias UptimeCheckerWeb.Api.V1.RoleView

  def render("index.json", %{roles: roles}) do
    %{data: render_many(roles, RoleView, "role.json")}
  end

  def render("show.json", %{role: role}) do
    %{data: render_one(role, RoleView, "role.json")}
  end

  def render("role.json", %{role: role}) do
    %{
      id: role.id,
      name: role.name,
      type: role.type
    }
  end
end
