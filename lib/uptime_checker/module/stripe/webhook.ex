defmodule UptimeChecker.Module.Stripe.Webhook do
  @behaviour Stripe.WebhookHandler

  @customer_subscription_created "customer.subscription.created"
  @customer_subscription_updated "customer.subscription.updated"
  @customer_subscription_deleted "customer.subscription.deleted"

  @invoice_created "invoice.created"
  @invoice_paid "invoice.paid"
  @invoice_payment_failed "invoice.payment_failed"
  @invoice_finalization_failed "invoice.finalization_failed"

  @impl true
  def handle_event(%Stripe.Event{type: @customer_subscription_created} = event) do
    IO.inspect(event)
  end

  @impl true
  def handle_event(%Stripe.Event{type: @customer_subscription_updated} = event) do
    IO.inspect(event)
  end

  @impl true
  def handle_event(%Stripe.Event{type: @customer_subscription_deleted} = event) do
    IO.inspect(event)
  end

  @impl true
  def handle_event(%Stripe.Event{type: @invoice_created} = event) do
    IO.inspect(event)
  end

  @impl true
  def handle_event(%Stripe.Event{type: @invoice_paid} = event) do
    IO.inspect(event)
  end

  @impl true
  def handle_event(%Stripe.Event{type: @invoice_payment_failed} = event) do
    IO.inspect(event)
  end

  @impl true
  def handle_event(%Stripe.Event{type: @invoice_finalization_failed} = event) do
    IO.inspect(event)
  end

  # Return HTTP 200 for unhandled events
  @impl true
  def handle_event(_event), do: :ok
end
