defmodule UptimeChecker.Schema.Payment.Product do
  use Ecto.Schema
  import Ecto.Changeset

  @tiers [free: 1, startup: 2, team: 3, business: 4]

  schema "payments" do
    field :name, :string
    field :description, :string
    field :external_id, :string
    field :tier, Ecto.Enum, values: @tiers

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(error_log, attrs) do
    error_log
    |> cast(attrs, [:name, :description, :external_id, :tier])
    |> validate_required([:name, :tier])
  end
end
