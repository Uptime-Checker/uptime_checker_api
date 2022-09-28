defmodule UptimeChecker.Service.ProductService do
  import Ecto.Query, warn: false

  alias UptimeChecker.Repo
  alias UptimeChecker.Error.RepoError
  alias UptimeChecker.Schema.Payment.{Product, Plan, Feature, ProductFeature}

  def create_product(attrs) do
    %Product{}
    |> Product.changeset(attrs)
    |> Repo.insert(
      on_conflict: [set: [name: attrs.name]],
      conflict_target: :name
    )
  end

  def create_feature(attrs) do
    %Feature{}
    |> Feature.changeset(attrs)
    |> Repo.insert()
  end

  def create_plan(attrs) do
    %Plan{}
    |> Plan.changeset(attrs)
    |> Repo.insert(
      on_conflict: [set: [price: attrs.price]],
      conflict_target: :external_id
    )
  end

  def create_product_feature(attrs) do
    %ProductFeature{}
    |> ProductFeature.changeset(attrs)
    |> Repo.insert()
  end

  def list_products_with_plan() do
    query =
      from product in Product,
        left_join: p in assoc(product, :plans),
        preload: [plans: p]

    Repo.all(query)
  end

  def get_feature!(id), do: Repo.get!(Feature, id)

  def get_feature_by_name_type(name, type) do
    query = from u in Feature, where: u.name == ^name, where: u.type == ^type

    case Repo.one(query) do
      nil -> {:error, RepoError.feature_not_found() |> ErrorMessage.not_found(%{name: name, type: type})}
      feature -> {:ok, feature}
    end
  end

  def get_product_by_name(name) do
    Product
    |> Repo.get_by(name: name)
    |> case do
      nil -> {:error, RepoError.product_not_found() |> ErrorMessage.not_found(%{name: name})}
      product -> {:ok, product}
    end
  end

  def get_plan_with_product(id) do
    query =
      from plan in Plan,
        left_join: p in assoc(plan, :product),
        where: plan.id == ^id,
        preload: [product: p]

    Repo.one(query)
    |> case do
      nil -> {:error, RepoError.plan_not_found() |> ErrorMessage.not_found(%{id: id})}
      plan -> {:ok, plan}
    end
  end

  def get_plan_with_product_from_external_id(id) do
    query =
      from plan in Plan,
        left_join: p in assoc(plan, :product),
        where: plan.external_id == ^id,
        preload: [product: p]

    Repo.one(query)
    |> case do
      nil -> {:error, RepoError.plan_not_found() |> ErrorMessage.not_found(%{external_id: id})}
      plan -> {:ok, plan}
    end
  end
end
