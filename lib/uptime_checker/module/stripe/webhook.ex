defmodule UptimeChecker.Module.Stripe.Webhook do
  use Timex
  require Logger

  @behaviour Stripe.WebhookHandler

  alias UptimeChecker.Constant
  alias UptimeChecker.Helper.Strings
  alias UptimeChecker.{Customer, ProductService, Payment}

  @customer_subscription_created "customer.subscription.created"
  @customer_subscription_updated "customer.subscription.updated"
  @customer_subscription_deleted "customer.subscription.deleted"

  @invoice_created "invoice.created"
  @invoice_paid "invoice.paid"
  @invoice_payment_failed "invoice.payment_failed"

  @checkout_session_completed "checkout.session.completed"

  @impl true
  def handle_event(%Stripe.Event{type: @customer_subscription_created} = event) do
    create_or_update_subscription(event)
    :ok
  end

  @impl true
  def handle_event(%Stripe.Event{type: @customer_subscription_updated} = event) do
    create_or_update_subscription(event)
    :ok
  end

  @impl true
  def handle_event(%Stripe.Event{type: @customer_subscription_deleted} = event) do
    create_or_update_subscription(event)
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
    create_or_update_receipt(event)
    :ok
  end

  @impl true
  def handle_event(%Stripe.Event{type: @checkout_session_completed} = event) do
    data = event.data.object
    {:ok, customer} = Stripe.Customer.retrieve(data.customer)
    dbg(customer)

    {:ok, payment_methods} =
      Stripe.PaymentMethod.list(%{customer: customer.id, type: Constant.Default.payment_method_type()})

    dbg(payment_methods)
    payment_method = Enum.at(payment_methods.data, 0)

    {:ok, user} = Customer.get_customer_by_payment_id(data.customer)
    {:ok, local_subscription} = Payment.get_active_subsription_from_user(user.organization_id)
    dbg(local_subscription)
    {:ok, remote_subscription} = Stripe.Subscription.retrieve(customer.id)
    dbg(remote_subscription)

    {:ok, updated_remote_subscription} =
      Stripe.Subscription.update(local_subscription.external_id, %{
        default_payment_method: payment_method.id
      })

    dbg(updated_remote_subscription)

    :ok
  end

  # Return HTTP 200 for unhandled events
  @impl true
  def handle_event(_event), do: :ok

  defp create_or_update_subscription(event) do
    data = event.data.object
    item = Enum.at(data.items.data, 0)
    {:ok, user} = Customer.get_customer_by_payment_id(data.customer)
    {:ok, plan} = ProductService.get_plan_with_product_from_external_id(item.price.id)

    params = %{
      status: data.status,
      starts_at: data.start_date |> Timex.from_unix(),
      expires_at: data.current_period_end |> Timex.from_unix(),
      canceled_at: get_canceled_at(data),
      is_trial: get_is_trial_subscription(data),
      external_id: data.id,
      external_customer_id: data.customer,
      plan: plan,
      product: plan.product,
      organization: user.organization
    }

    {:ok, subscription} = Payment.create_subscription(params)
    Logger.info("Subscription #{subscription.id} for org #{user.organization.id}, plan #{plan.id}, event #{event.type}")
  end

  defp create_or_update_receipt(event) do
    data = event.data.object
    line = Enum.at(data.lines.data, 0)
    {:ok, user} = Customer.get_customer_by_payment_id(data.customer)
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
      paid_at: get_paid_at(event),
      from: data.period_start |> Timex.from_unix() |> Timex.to_date(),
      to: data.period_end |> Timex.from_unix() |> Timex.to_date(),
      is_trial: String.contains?(line.description, "Trial"),
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

  defp get_paid_at(event) do
    if event.type == @invoice_paid do
      Timex.from_unix(event.created)
    else
      nil
    end
  end

  defp get_canceled_at(data) do
    if Strings.blank?(data.canceled_at) do
      nil
    else
      data.canceled_at |> Timex.from_unix()
    end
  end

  defp get_is_trial_subscription(data) do
    if Strings.blank?(data.trial_end) do
      false
    else
      now = Timex.now()
      trial_end = data.trial_end |> Timex.from_unix()
      Timex.after?(trial_end, now)
    end
  end
end
