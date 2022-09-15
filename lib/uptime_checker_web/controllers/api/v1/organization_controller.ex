defmodule UptimeCheckerWeb.Api.V1.OrganizationController do
  use UptimeCheckerWeb, :controller

  alias UptimeChecker.Customer
  alias UptimeChecker.ProductService
  alias UptimeChecker.Schema.Customer.Organization

  action_fallback UptimeCheckerWeb.FallbackController

  def create(conn, params) do
    user = current_user(conn)

    with {:ok, plan} <- ProductService.get_plan_with_product(params["plan_id"]),
         {:ok, %Organization{} = organization} <- Customer.create_organization(params, user),
         {:ok, updated_user} <- UptimeChecker.Module.Stripe.User.create_stripe_customer(user) do
      {:ok, subscription} = UptimeChecker.Module.Stripe.Billing.create_subscription(updated_user, plan)

      conn
      |> put_status(:created)
      |> render("show.json", %{organization: organization, subscription: subscription, plan: plan})
    end
  end
end
