defmodule UptimeCheckerWeb.Api.V1.SubscriptionView do
  use UptimeCheckerWeb, :view
  alias UptimeCheckerWeb.Api.V1.SubscriptionView

  def render("index.json", %{subscriptions: subscriptions}) do
    %{data: render_many(subscriptions, SubscriptionView, "subscription.json")}
  end

  def render("show.json", %{subscription: subscription}) do
    %{data: render_one(subscription, SubscriptionView, "subscription.json")}
  end

  def render("subscription.json", %{subscription: subscription}) do
    %{
      id: subscription.id,
      status: subscription.status,
      starts_at: subscription.starts_at,
      expires_at: subscription.expires_at,
      is_trial: subscription.is_trial
    }
  end
end
