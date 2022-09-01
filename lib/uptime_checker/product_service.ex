defmodule UptimeChecker.ProductService do
  import Ecto.Query, warn: false

  alias UptimeChecker.Repo
  alias UptimeChecker.Schema.Payment.{Product, Plan}

  def create_product(attrs) do
    %Product{}
    |> Product.changeset(attrs)
    |> Repo.insert(
      on_conflict: [set: [name: attrs.name]],
      conflict_target: :name
    )
  end

  def create_plan(attrs) do
    %Plan{}
    |> Plan.changeset(attrs)
    |> Repo.insert(
      on_conflict: [set: [price: attrs.price]],
      conflict_target: :external_id
    )
  end
end
