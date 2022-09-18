defmodule UptimeChecker.Schema.Customer.Organization do
  use Ecto.Schema
  import Ecto.Changeset

  alias UptimeChecker.Schema.Customer.User
  alias UptimeChecker.Schema.Payment.Subscription

  schema "organizations" do
    field :name, :string
    field :slug, :string

    has_many :users, User
    has_many :subscriptions, Subscription

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(organization, attrs) do
    organization
    |> cast(attrs, [:name, :slug])
    |> validate_required([:name, :slug])
    |> unique_constraint(:slug)
  end
end
