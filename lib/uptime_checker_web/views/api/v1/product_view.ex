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
    %{
      id: product.id,
      name: product.name,
      description: product.description,
      external_id: product.external_id,
      plans: get_plans(product),
      features: get_features(product)
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

  defp render_plan(plan) do
    %{
      id: plan.id,
      price: plan.price,
      type: plan.type
    }
  end

  defp render_feature(feature) do
    %{
      id: feature.id,
      name: feature.name,
      type: feature.type
    }
  end

  defp get_plans(product) when is_list(product.plans) == true do
    Enum.map(product.plans, fn plan -> render_plan(plan) end)
  end

  defp get_plans(_product), do: nil

  defp get_features(product) when is_list(product.features) == true do
    Enum.map(product.features, fn feature -> render_feature(feature) end)
  end

  defp get_features(_product), do: nil
end
