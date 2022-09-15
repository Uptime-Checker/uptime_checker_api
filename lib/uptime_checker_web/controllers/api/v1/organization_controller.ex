defmodule UptimeCheckerWeb.Api.V1.OrganizationController do
  use Timex
  use UptimeCheckerWeb, :controller

  alias UptimeChecker.Constant
  alias UptimeChecker.ProductService
  alias UptimeChecker.{Customer, Payment}
  alias UptimeChecker.Schema.Payment.Subscription
  alias UptimeChecker.Schema.Customer.Organization

  action_fallback UptimeCheckerWeb.FallbackController

  def create(conn, params) do
    user = current_user(conn)
    now = Timex.now()

    with {:ok, plan} <- ProductService.get_plan_with_product(params["plan_id"]),
         {:ok, %Organization{} = organization} <- Customer.create_organization(params, user),
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
      conn
      |> put_status(:created)
      |> render("show.json", %{organization: organization, subscription: subscription, plan: plan})
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
