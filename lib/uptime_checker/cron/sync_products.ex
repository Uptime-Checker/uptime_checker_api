defmodule UptimeChecker.Cron.SyncProducts do
  alias UptimeChecker.ProductService

  def work do
    {:ok, products} = Stripe.Product.list()
    {:ok, prices} = Stripe.Price.list()

    Enum.each(products.data, fn product ->
      with {:ok, product} <-
             ProductService.create_product(%{
               name: product.name,
               description: product.description,
               external_id: product.id,
               tier: product.metadata["tier"]
             }) do
        filtered_prices =
          Enum.filter(prices.data, fn price ->
            if price.product == product.external_id do
              price
            end
          end)

        Enum.each(filtered_prices, fn price ->
          plan_type =
            if price.recurring.interval == "year" do
              :yearly
            else
              :monthly
            end

          ProductService.create_plan(%{
            price: price.unit_amount / 100,
            external_id: price.id,
            type: plan_type,
            product: product
          })
        end)
      end
    end)
  end
end
