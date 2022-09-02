defmodule UptimeChecker.Module.Stripe.Webhook do
  use Timex
  require Logger

  @behaviour Stripe.WebhookHandler

  alias UptimeChecker.Helper.Strings
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
    create_or_update_receipt(event)
    :ok
  end

  @impl true
  def handle_event(%Stripe.Event{type: @invoice_paid} = event) do
    create_or_update_receipt(event)
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

  defp create_or_update_receipt(event) do
    data = event.data
    line = Enum.at(data.lines.data, 0)
    {:ok, user} = Customer.get_customer_by_payment_id(event.data.customer)
    {:ok, plan} = ProductService.get_plan_with_product_from_external_id(line.price.id)

    params = %{
      price: round(data.amount_due / 100),
      currency: data.currency,
      external_id: data.id,
      external_customer_id: data.customer,
      subscription_id: get_subscription_id(data),
      url: data.hosted_invoice_url,
      status: data.status,
      paid: data.paid,
      from: Timex.from_unix(data.period_start),
      to: Timex.from_unix(data.period_end),
      is_trial: false,
      plan: plan,
      product: plan.product,
      organization: user.organization
    }

    {:ok, receipt} = Payment.create_receipt(params)
    Logger.info("Receipt #{receipt.id} for org #{user.organization.id}, plan #{plan.id}, event #{event.type}")
  end

  defp get_subscription_id(data) do
    if Strings.blank?(data.subscription) do
      nil
    else
      case Payment.get_subscription_by_external_id(data.subscription) do
        {:ok, subscription} ->
          subscription.id

        {:error, %ErrorMessage{code: :not_found} = _e} ->
          nil
      end
    end
  end
end
