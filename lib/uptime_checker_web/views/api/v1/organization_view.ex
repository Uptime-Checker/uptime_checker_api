defmodule UptimeCheckerWeb.Api.V1.OrganizationView do
  use UptimeCheckerWeb, :view

  alias UptimeCheckerWeb.Api.V1.RoleView
  alias UptimeCheckerWeb.Api.V1.PlanView
  alias UptimeCheckerWeb.Api.V1.PaymentView
  alias UptimeCheckerWeb.Api.V1.OrganizationView
  alias UptimeChecker.Schema.Customer.OrganizationUser

  def render("index.json", %{organization_users: organization_users}) do
    %{data: Enum.map(organization_users, fn organization_user -> render_organization_user(organization_user) end)}
  end

  def render("index.json", %{organizations: organizations}) do
    %{data: render_many(organizations, OrganizationView, "organization.json")}
  end

  def render("show.json", %{organization: organization, subscription: subscription, plan: plan}) do
    %{
      data: %{
        id: organization.id,
        name: organization.name,
        slug: organization.slug,
        subscription: render_sub(subscription),
        plan: render_plan(plan)
      }
    }
  end

  def render("show.json", %{organization: organization}) do
    %{data: render_one(organization, OrganizationView, "organization.json")}
  end

  def render("organization.json", %{organization: organization}) do
    %{
      id: organization.id,
      name: organization.name,
      slug: organization.slug
    }
  end

  def render_organization_user(%OrganizationUser{} = organization_user) do
    %{
      role: render_role(organization_user.role),
      organization: render_one(organization_user.organization, OrganizationView, "organization.json")
    }
  end

  defp render_sub(%{:id => _id} = sub) do
    render_one(sub, PaymentView, "subscription.json")
  end

  defp render_sub(_sub), do: nil

  defp render_plan(%{:id => _id} = plan) do
    render_one(plan, PlanView, "plan.json")
  end

  defp render_plan(_plan), do: nil

  defp render_role(%{:id => _id} = role) do
    render_one(role, RoleView, "role.json")
  end

  defp render_role(_role), do: nil
end
