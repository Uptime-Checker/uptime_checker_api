defmodule UptimeCheckerWeb.Api.V1.PaymentView do
  use UptimeCheckerWeb, :view

  alias UptimeCheckerWeb.Api.V1.{PaymentView, PlanView, ProductView}

  def render("index.json", %{subscriptions: subscriptions}) do
    %{data: render_many(subscriptions, PaymentView, "subscription.json")}
  end

  def render("show.json", %{subscription: subscription}) do
    %{data: render_one(subscription, PaymentView, "subscription.json")}
  end

  def render("subscription.json", %{payment: subscription}) do
    %{
      id: subscription.id,
      status: subscription.status,
      starts_at: subscription.starts_at,
      expires_at: subscription.expires_at,
      is_trial: subscription.is_trial,
      product: render_product(subscription.product),
      plan: render_plan(subscription.plan)
    }
  end

  defp render_product(%{:id => _id} = product) do
    render_one(product, ProductView, "product.json")
  end

  defp render_product(_product), do: nil

  defp render_plan(%{:id => _id} = plan) do
    render_one(plan, PlanView, "plan.json")
  end

  defp render_plan(_plan), do: nil
end
