defmodule UptimeChecker.Customer.Organization do
  use Ecto.Schema
  import Ecto.Changeset

  schema "organizations" do
    field :name, :string
    field :slug, :string

    timestamps()
  end

  @doc false
  def changeset(organization, attrs) do
    organization
    |> cast(attrs, [:name, :slug])
    |> validate_required([:name, :slug])
  end
end
