defmodule UptimeChecker.Module.Stripe.User do
  alias UptimeChecker.Customer
  alias UptimeChecker.Helper.Strings
  alias UptimeChecker.Schema.Customer.User

  def create_stripe_customer(%User{} = user) do
    if Strings.blank?(user.payment_customer_id) do
      {:ok, stripe_customer} = Stripe.Customer.create(%{name: user.name, email: user.email})
      Customer.update_payment_customer(user, stripe_customer.id)
    else
      {:ok, user}
    end
  end
end
