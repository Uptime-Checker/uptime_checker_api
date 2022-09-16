defmodule UptimeChecker.Cache.Payment do
  @cache_payment :cache_payment
  @cache_stripe_webhook :cache_stripe_webhook

  # =============== Products
  def get_products(key) do
    Cachex.get!(@cache_payment, key)
  end

  def put_products(key, data) do
    Cachex.put(@cache_payment, key, data)
    Cachex.expire(@cache_payment, key, :timer.minutes(60))
  end

  # =============== Subscription Events
  def get_subscription_event(customer) do
    key = get_subscription_event_key(customer)
    Cachex.get!(@cache_stripe_webhook, key)
  end

  def put_subscription_event(customer, event_at) do
    key = get_subscription_event_key(customer)
    Cachex.put(@cache_stripe_webhook, key, event_at)
    Cachex.expire(@cache_stripe_webhook, key, :timer.minutes(5))
  end

  defp get_subscription_event_key(customer), do: "subscription_event_#{customer}"

  # =============== Receipt Events
  def get_receipt_event(customer) do
    key = get_receipt_event_key(customer)
    Cachex.get!(@cache_stripe_webhook, key)
  end

  def put_receipt_event(customer, event_at) do
    key = get_receipt_event_key(customer)
    Cachex.put(@cache_stripe_webhook, key, event_at)
    Cachex.expire(@cache_stripe_webhook, key, :timer.minutes(5))
  end

  defp get_receipt_event_key(customer), do: "receipt_event_#{customer}"
end
