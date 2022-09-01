defmodule UptimeCheckerWeb.Api.V1.ProductView do
  use UptimeCheckerWeb, :view
  alias UptimeCheckerWeb.Api.V1.ProductView

  def render("index.json", %{products: products}) do
    %{data: render_many(products, ProductView, "product.json")}
  end

  def render("show.json", %{product: product}) do
    %{data: render_one(product, ProductView, "product.json")}
  end

  def render("product.json", %{product: product}) do
    plans = Enum.map(product.plans, fn plan -> render_plan(plan) end)

    %{
      id: product.id,
      name: product.name,
      description: product.description,
      external_id: product.external_id,
      plans: plans
    }
  end

  def render("external_products_index.json", %{external_products: products}) do
    %{data: render_many(products, ProductView, "external_product.json")}
  end

  def render("external_product.json", %{product: product}) do
    prices = Enum.map(product.prices, fn price -> render_price(price) end)

    %{
      id: product.id,
      name: product.name,
      prices: prices
    }
  end

  def render_price(%{:id => _id} = price) do
    %{
      id: price.id,
      cost: price.unit_amount / 100,
      currency: price.currency,
      type: price.type,
      interval: price.recurring.interval,
      trial_period_days: price.recurring.trial_period_days
    }
  end

  def render_plan(plan) do
    %{
      id: plan.id,
      price: plan.price,
      type: plan.type
    }
  end
end
