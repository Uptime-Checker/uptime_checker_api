defmodule UptimeChecker.WatchDog.Region do
  use Ecto.Schema
  import Ecto.Changeset

  schema "regions" do
    field :ip_address, :string
    field :key, :string
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(region, attrs) do
    region
    |> cast(attrs, [:name, :key, :ip_address])
    |> validate_required([:name, :key, :ip_address])
  end
end
