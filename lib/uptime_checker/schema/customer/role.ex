defmodule UptimeChecker.Schema.Customer.Role do
  use Ecto.Schema
  import Ecto.Changeset

  @role_types [superadmin: 1, admin: 2, editor: 3, member: 4]

  schema "roles" do
    field :name, :string
    field :type, Ecto.Enum, values: @role_types

    timestamps(type: :utc_datetime)
  end

  def changeset(role, attrs) do
    role
    |> cast(attrs, [:name, :type])
    |> validate_required([:name, :type])
    |> unique_constraint(:type)
  end
end
