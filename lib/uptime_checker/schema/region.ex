defmodule UptimeChecker.Schema.Region do
  use Ecto.Schema
  import Ecto.Changeset

  schema "regions" do
    field :name, :string
    field :key, :string
    field :ip_address, :string
    field :default, :boolean, default: false

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(region, attrs) do
    region
    |> cast(attrs, [:name, :key, :ip_address])
    |> validate_required([:name, :key])
    |> unique_constraint(:key)
  end
end
