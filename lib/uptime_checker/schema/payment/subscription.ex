defmodule UptimeChecker.Schema.Payment.Subscription do
  use Ecto.Schema
  import Ecto.Changeset

  alias UptimeChecker.Schema.Customer.Organization
  alias UptimeChecker.Schema.Payment.{Product, Plan}

  schema "subscriptions" do
    field :expires_at, :utc_datetime
    field :cancelled_at, :utc_datetime
    field :is_trial, :boolean
    field :external_id, :string
    field :external_customer_id, :string

    belongs_to :plan, Plan
    belongs_to :product, Product
    belongs_to :organization, Organization

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(subscription, attrs) do
    subscription
    |> cast(attrs, [:expires_at, :cancelled_at, :is_trial, :external_id, :external_customer_id])
    |> validate_required([:expires_at, :is_trial])
    |> unique_constraint(:external_id)
    |> put_assoc(:plan, attrs.plan)
    |> put_assoc(:product, attrs.product)
    |> put_assoc(:organization, attrs.organization)
  end
end
