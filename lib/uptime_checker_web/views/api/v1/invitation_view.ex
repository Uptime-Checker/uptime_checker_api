defmodule UptimeCheckerWeb.Api.V1.InvitationView do
  use UptimeCheckerWeb, :view

  alias UptimeCheckerWeb.Api.V1.RoleView
  alias UptimeCheckerWeb.Api.V1.InvitationView
  alias UptimeCheckerWeb.Api.V1.OrganizationView

  def render("index.json", %{invitations: invitations}) do
    %{data: render_many(invitations, InvitationView, "invitation.json")}
  end

  def render("show.json", %{invitation: invitation}) do
    %{data: render_one(invitation, InvitationView, "invitation.json")}
  end

  def render("invitation.json", %{invitation: invitation}) do
    %{
      id: invitation.id,
      email: invitation.email,
      role: render_role(invitation.role),
      organization: render_org(invitation.organization)
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
