defmodule UptimeChecker.Schema.Payment.ProductFeature do
  use Ecto.Schema
  import Ecto.Changeset

  alias UptimeChecker.Schema.Payment.Product
  alias UptimeChecker.Schema.Payment.Feature

  schema "product_feature_junction" do
    field :count, :integer

    belongs_to :product, Product
    belongs_to :feature, Feature

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(product_feature, attrs) do
    product_feature
    |> cast(attrs, [:product_id, :feature_id, :count])
    |> validate_required([:count])
    |> put_assoc(:product, attrs.product)
    |> put_assoc(:feature, attrs.feature)
    |> unique_constraint([:product_id, :feature_id])
  end
end
