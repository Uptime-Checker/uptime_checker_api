defmodule UptimeCheckerWeb.Api.V1.UserView do
  use UptimeCheckerWeb, :view

  alias UptimeCheckerWeb.Api.V1.{UserView, RoleView}
  alias UptimeCheckerWeb.Api.V1.{OrganizationView, PaymentView}

  def render("index.json", %{users: users}) do
    %{data: render_many(users, UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, UserView, "user.json")}
  end

  def render("full_info.json", %{user: user, subscription: subscription, organization_users: organization_users}) do
    dbg(organization_users)

    %{
      data: %{
        user: render_one(user, UserView, "user.json"),
        subscription: render_one(subscription, PaymentView, "subscription.json"),
        organization_users:
          Enum.map(organization_users, fn organization_user ->
            OrganizationView.render_organization_user(organization_user)
          end)
      }
    }
  end

  def render("user.json", %{user: user}) do
    %{
      id: user.id,
      name: user.name,
      email: user.email,
      payment_customer_id: user.payment_customer_id,
      role: render_role(user.role),
      organization: render_org(user.organization)
    }
  end

  def render("show.json", %{guest_user: guest_user, code: code}) do
    %{
      data: %{
        id: guest_user.id,
        email: guest_user.email,
        code: code,
        expires_at: guest_user.expires_at
      }
    }
  end

  def render("show.json", %{guest_user: guest_user}) do
    %{data: render_one(guest_user, UserView, "guest_user.json")}
  end

  def render("guest_user.json", %{user: guest_user}) do
    %{
      id: guest_user.id,
      email: guest_user.email,
      expires_at: guest_user.expires_at
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
