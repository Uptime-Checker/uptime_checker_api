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
    |> cast(attrs, [:name, :code, :descripition])
    |> validate_required([:name, :code, :descripition])
    |> validate_inclusion(:code, 200..499)
  end
end
