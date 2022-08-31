defmodule UptimeChecker.Schema.Payment.Plan do
  use Ecto.Schema
  import Ecto.Changeset

  alias UptimeChecker.Schema.Payment.Product

  @types [monthly: 1, yearly: 2]

  schema "plans" do
    field :price, :float
    field :external_id, :string
    field :type, Ecto.Enum, values: @types

    belongs_to :product, Product

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(plan, attrs) do
    plan
    |> cast(attrs, [:price, :external_id, :type])
    |> validate_required([:price, :type])
    |> put_assoc(:product, attrs.product)
  end
end
