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
    # TODO: handle the charge.succeeded event
  end

  @impl true
  def handle_event(%Stripe.Event{type: @customer_subscription_deleted} = event) do
    # TODO: handle the invoice.payment_failed event
  end

  # Return HTTP 200 for unhandled events
  @impl true
  def handle_event(_event), do: :ok
end
