defmodule UptimeChecker.Module.Stripe.Billing do
  use Timex

  alias UptimeChecker.Constant.Default
  alias UptimeChecker.Schema.Payment.Plan
  alias UptimeChecker.Schema.Customer.User

  def create_subscription(%User{} = user, %Plan{} = plan, is_trial) do
    get_create_subscription_params(user, plan, is_trial) |> Stripe.Subscription.create()
  end

  defp get_create_subscription_params(%User{} = user, %Plan{} = plan, is_trial) when is_trial == false do
    %{customer: user.payment_customer_id, items: [%{price: plan.external_id}]}
  end

  defp get_create_subscription_params(%User{} = user, %Plan{} = plan, is_trial) when is_trial == true do
    trial_end = Timex.now() |> Timex.shift(days: Default.trial_duration_in_days()) |> Timex.to_unix()
    %{customer: user.payment_customer_id, items: [%{price: plan.external_id}], trial_end: trial_end}
  end
end
