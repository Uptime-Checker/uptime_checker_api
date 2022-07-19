defmodule UptimeCheckerWeb.Api.V1.UserView do
  use UptimeCheckerWeb, :view
  alias UptimeCheckerWeb.Api.V1.UserView
  alias UptimeCheckerWeb.Api.V1.OrganizationView

  def render("index.json", %{users: users}) do
    %{data: render_many(users, UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{
      id: user.id,
      name: user.name,
      email: user.email,
      organization: render_one(user.organization, OrganizationView, "organization.json")
    }
  end
end
