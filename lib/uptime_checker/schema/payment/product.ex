defmodule UptimeChecker.Schema.Payment.Product do
  use Ecto.Schema
  import Ecto.Changeset
  alias UptimeChecker.Schema.Payment.Plan

  @tiers [free: 1, developer: 2, startup: 3, enterprise: 4]

  schema "products" do
    field :name, :string
    field :description, :string
    field :external_id, :string
    field :tier, Ecto.Enum, values: @tiers

    has_many :plans, Plan

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [:name, :description, :external_id, :tier])
    |> validate_required([:name, :tier])
    |> unique_constraint(:name)
    |> unique_constraint(:tier)
    |> unique_constraint(:external_id)
  end
end
