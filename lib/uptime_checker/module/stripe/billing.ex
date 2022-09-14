defmodule UptimeChecker.Module.Stripe.Billing do
  alias UptimeChecker.Schema.Payment.Plan
  alias UptimeChecker.Schema.Customer.User

  def create_subscription(%User{} = user, %Plan{} = plan) do
    Stripe.Subscription.create(%{customer: user.payment_customer_id, items: [%{price: plan.external_id}]})
  end
end
