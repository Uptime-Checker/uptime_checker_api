defmodule UptimeChecker.Schema.Region do
  use Ecto.Schema
  import Ecto.Changeset

  schema "regions" do
    field :name, :string
    field :key, :string
    field :ip_address, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(region, attrs) do
    region
    |> cast(attrs, [:name, :key, :ip_address])
    |> validate_required([:name, :key, :ip_address])
  end
end
