defmodule UptimeChecker.Schema.Customer.Invitation do
  use Ecto.Schema
  import Ecto.Changeset

  alias UptimeChecker.Schema.Customer.{Organization, Role}

  schema "invitations" do
    field :email, :string
    field :code, :string
    field :expires_at, :utc_datetime

    belongs_to :role, Role
    belongs_to :organization, Organization

    timestamps(type: :utc_datetime)
  end

  def changeset(invitation, attrs) do
    invitation
    |> cast(attrs, [:email, :code, :expires_at])
    |> validate_required([:email, :code, :expires_at])
    |> validate_length(:code, min: 10, max: 30)
    |> unique_constraint(:code)
    |> unique_constraint([:organization_id, :email])
    |> put_assoc(:role, attrs.role)
    |> put_assoc(:organization, attrs.organization)
  end
end
