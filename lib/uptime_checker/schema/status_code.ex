defmodule UptimeChecker.Schema.StatusCode do
  use Ecto.Schema
  import Ecto.Changeset

  schema "status_codes" do
    field :name, :string
    field :code, :integer
    field :descripition, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(region, attrs) do
    region
    |> cast(attrs, [:name, :key, :ip_address])
    |> validate_required([:name, :key, :ip_address])
  end
end
