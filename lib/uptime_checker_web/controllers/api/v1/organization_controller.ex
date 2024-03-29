defmodule UptimeCheckerWeb.Api.V1.OrganizationController do
  use Timex
  use UptimeCheckerWeb, :controller

  alias UptimeChecker.Cache
  alias UptimeChecker.Constant
  alias UptimeChecker.Authorization
  alias UptimeChecker.{Customer, Payment}
  alias UptimeChecker.Service.ProductService
  alias UptimeChecker.Schema.Payment.Subscription
  alias UptimeChecker.Schema.Customer.Organization

  action_fallback UptimeCheckerWeb.FallbackController

  def create(conn, params) do
    user = current_user(conn)
    now = Timex.now()

    attrs = params |> Map.put("slug", params["slug"] |> String.downcase() |> String.replace(" ", "-"))

    with {:ok, plan} <- ProductService.get_plan_with_product(attrs["plan_id"]),
         {:ok, %Organization{} = organization} <- Customer.create_organization(attrs, user),
         {:ok, %Subscription{} = subscription} <-
           Payment.create_subscription(%{
             status: get_status(plan),
             starts_at: now,
             expires_at: get_expired_at(now, plan),
             canceled_at: nil,
             is_trial: is_trial(plan),
             plan: plan,
             product: plan.product,
             organization: organization
           }) do
      Cache.User.bust(user.id)

      conn
      |> put_status(:created)
      |> render("show.json", %{organization: organization, subscription: subscription, plan: plan})
    end
  end

  def index(conn, _params) do
    user = current_user(conn)

    cached_organization_users = Cache.User.get_organizations(user.id)

    if is_nil(cached_organization_users) do
      organization_users = Authorization.list_organizations_of_user(user)
      Cache.User.put_organizations(user.id, organization_users)
      render(conn, "index.json", organization_users: organization_users)
    else
      render(conn, "index.json", organization_users: cached_organization_users)
    end
  end

  defp is_trial(plan) when plan.product.tier == :free, do: false
  defp is_trial(_plan), do: true

  defp get_expired_at(now, plan) when plan.product.tier == :free do
    Timex.shift(now, months: Constant.Default.free_duration_in_months())
  end

  defp get_expired_at(now, _plan) do
    Timex.shift(now, days: Constant.Default.trial_duration_in_days())
  end

  defp get_status(plan) when plan.product.tier == :free, do: :active
  defp get_status(_plan), do: :trialing
end
