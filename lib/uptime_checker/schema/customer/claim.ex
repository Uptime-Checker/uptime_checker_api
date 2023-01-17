defmodule UptimeChecker.Schema.Customer.Claim do
  use Ecto.Schema
  import Ecto.Changeset

  schema "claims" do
    field :name, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(claim, attrs) do
    claim
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint([:name])
  end
end
