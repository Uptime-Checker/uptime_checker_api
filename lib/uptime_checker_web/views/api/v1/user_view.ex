defmodule UptimeCheckerWeb.Api.V1.UserView do
  use UptimeCheckerWeb, :view

  alias UptimeCheckerWeb.Api.V1.RoleView
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
      role: render_role(user.role),
      organization: render_org(user.organization)
    }
  end

  def render("show.json", %{guest_user: guest_user}) do
    %{data: render_one(guest_user, UserView, "guest_user.json")}
  end

  def render("guest_user.json", %{user: guest_user}) do
    %{
      id: guest_user.id,
      email: guest_user.email
    }
  end

  defp render_org(%{:id => _id} = org) do
    render_one(org, OrganizationView, "organization.json")
  end

  defp render_org(_org), do: nil

  defp render_role(%{:id => _id} = role) do
    render_one(role, RoleView, "role.json")
  end

  defp render_role(_role), do: nil
end
