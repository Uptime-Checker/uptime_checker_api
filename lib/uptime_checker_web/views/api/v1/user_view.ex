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
      organization: render_org(user.organization)
    }
  end

  defp render_org(%{:id => _id} = org) do
    render_one(org, OrganizationView, "organization.json")
  end

  defp render_org(_org), do: nil
end
