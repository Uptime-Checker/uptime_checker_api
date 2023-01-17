defmodule UptimeChecker.Schema.Payment.Feature do
  use Ecto.Schema
  import Ecto.Changeset

  @types [
    monitoring: 1,
    incidents: 2,
    status_page: 3,
    oncall: 4,
    alert: 5,
    support: 6,
    integration: 7,
    security: 8,
    analytics: 9,
    team: 10
  ]

  schema "features" do
    field :name, :string
    field :type, Ecto.Enum, values: @types

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(feature, attrs) do
    feature
    |> cast(attrs, [:name, :type])
    |> validate_required([:name, :type])
    |> unique_constraint([:name, :type])
  end
end
