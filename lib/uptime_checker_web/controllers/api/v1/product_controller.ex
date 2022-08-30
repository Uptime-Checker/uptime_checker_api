defmodule UptimeCheckerWeb.Api.V1.ProductController do
  use UptimeCheckerWeb, :controller

  alias UptimeChecker.Cache
  alias UptimeChecker.Constant
  alias UptimeChecker.TaskSupervisor

  action_fallback UptimeCheckerWeb.FallbackController

  def list_external_products(conn, _params) do
    cached_products = Cache.Payment.get(Constant.Cache.products())

    if is_nil(cached_products) do
      products_fetch_task =
        Task.Supervisor.async(TaskSupervisor, fn ->
          Stripe.Product.list()
        end)

      prices_fetch_task =
        Task.Supervisor.async(TaskSupervisor, fn ->
          Stripe.Price.list()
        end)

      tasks = Task.await_many([products_fetch_task, prices_fetch_task])
      {:ok, products} = Enum.at(tasks, 0)
      {:ok, prices} = Enum.at(tasks, 1)

      updated_products =
        Enum.map(products.data, fn product ->
          filtered_prices =
            Enum.filter(prices.data, fn price ->
              if price.product == product.id do
                price
              end
            end)

          product |> Map.put(:prices, filtered_prices)
        end)

      Cache.Payment.put(Constant.Cache.products(), updated_products)

      render(conn, "external_products_index.json", external_products: updated_products)
    else
      render(conn, "external_products_index.json", external_products: cached_products)
    end
  end
end
