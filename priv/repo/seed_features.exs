# mix run priv/repo/seed_features.exs

alias UptimeChecker.Constant
alias UptimeChecker.ProductService

# Products
{:ok, free_product} = ProductService.get_product_by_name("Free")

{:ok, monitoring_api_check_count} =
  ProductService.get_feature_by_name_type(Constant.Feature.api_check_count(), :monitoring)
{:ok, monitoring_api_check_interval} =
  ProductService.get_feature_by_name_type(Constant.Feature.api_check_interval(), :monitoring)
{:ok, team_user_count} = ProductService.get_feature_by_name_type(Constant.Feature.user_count(), :team)

# Product features
ProductService.create_product_feature(%{product: free_product, feature: monitoring_api_check_count, count: 5})
ProductService.create_product_feature(%{product: free_product, feature: monitoring_api_check_interval, count: 300})
ProductService.create_product_feature(%{product: free_product, feature: team_user_count, count: 1})
