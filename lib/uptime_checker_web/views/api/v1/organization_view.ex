defmodule UptimeCheckerWeb.Api.V1.OrganizationView do
  use UptimeCheckerWeb, :view
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
end
