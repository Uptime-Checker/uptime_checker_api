defmodule UptimeChecker.Schema.Payment.Receipt do
  use Ecto.Schema
  import Ecto.Changeset

  alias UptimeChecker.Schema.Customer.Organization
  alias UptimeChecker.Schema.Payment.{Product, Plan, Subscription}

  @status_types [draft: 1, open: 2, paid: 3, void: 4, uncollectible: 5]

  schema "receipts" do
    field :price, :float
    field :currency, :float
    field :external_id, :string
    field :external_customer_id, :string
    field :url, :string
    field :status, Ecto.Enum, values: @status_types
    field :paid, :boolean
    field :paid_at, :utc_datetime
    field :from, :date
    field :to, :date
    field :is_trial, :boolean

    belongs_to :plan, Plan
    belongs_to :product, Product
    belongs_to :subscription, Subscription
    belongs_to :organization, Organization

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(receipt, attrs) do
    receipt
    |> cast(attrs, [
      :price,
      :currency,
      :external_id,
      :external_customer_id,
      :subscription_id,
      :url,
      :status,
      :paid,
      :paid_at,
      :from,
      :to,
      :is_trial
    ])
    |> validate_required([:price, :from, :to, :is_trial])
    |> unique_constraint(:external_id)
    |> put_assoc(:plan, attrs.plan)
    |> put_assoc(:product, attrs.product)
    |> put_assoc(:subscription, attrs.subscription)
    |> put_assoc(:organization, attrs.organization)
  end
end
