defmodule UptimeChecker.Module.Stripe.Webhook do
  @behaviour Stripe.WebhookHandler

  alias UptimeChecker.{Customer, ProductService, Payment}

  @customer_subscription_created "customer.subscription.created"
  @customer_subscription_updated "customer.subscription.updated"
  @customer_subscription_deleted "customer.subscription.deleted"

  @invoice_created "invoice.created"
  @invoice_paid "invoice.paid"
  @invoice_payment_failed "invoice.payment_failed"
  @invoice_finalization_failed "invoice.finalization_failed"

  @impl true
  def handle_event(%Stripe.Event{type: @customer_subscription_created} = event) do
    :ok
  end

  @impl true
  def handle_event(%Stripe.Event{type: @customer_subscription_updated} = event) do
    :ok
  end

  @impl true
  def handle_event(%Stripe.Event{type: @customer_subscription_deleted} = event) do
    :ok
  end

  @impl true
  def handle_event(%Stripe.Event{type: @invoice_created} = event) do
    {:ok, user} = Customer.get_customer_by_payment_id(event.data.customer)
    {:ok, plan} = ProductService.get_plan_with_product_from_external_id(event.data.customer)
  end

  @impl true
  def handle_event(%Stripe.Event{type: @invoice_paid} = event) do
    :ok
  end

  @impl true
  def handle_event(%Stripe.Event{type: @invoice_payment_failed} = event) do
    :ok
  end

  @impl true
  def handle_event(%Stripe.Event{type: @invoice_finalization_failed} = event) do
    :ok
  end

  # Return HTTP 200 for unhandled events
  @impl true
  def handle_event(_event), do: :ok
end
