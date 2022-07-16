defmodule UptimeChecker.Customer.Organization do
  use Ecto.Schema
  import Ecto.Changeset

  schema "organizations" do
    field :key, :string
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(organization, attrs) do
    organization
    |> cast(attrs, [:name, :key])
    |> validate_required([:name, :key])
  end
end
