defmodule UptimeCheckerWeb.Api.V1.OrganizationView do
  use UptimeCheckerWeb, :view

  alias UptimeCheckerWeb.Api.V1.PlanView
  alias UptimeCheckerWeb.Api.V1.SubscriptionView
  alias UptimeCheckerWeb.Api.V1.OrganizationView

  def render("index.json", %{organizations: organizations}) do
    %{data: render_many(organizations, OrganizationView, "organization.json")}
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

  def render("organization.json", %{organization: organization, subscription: subscription, plan: plan}) do
    %{
      id: organization.id,
      name: organization.name,
      slug: organization.slug,
      subscription: render_sub(subscription),
      plan: render_plan(plan)
    }
  end

  defp render_sub(%{:id => _id} = sub) do
    render_one(sub, SubscriptionView, "subscription.json")
  end

  defp render_sub(_sub), do: nil

  defp render_plan(%{:id => _id} = plan) do
    render_one(plan, PlanView, "plan.json")
  end

  defp render_plan(_plan), do: nil
end
