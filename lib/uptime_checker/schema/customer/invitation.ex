defmodule UptimeChecker.Schema.Customer.Invitation do
  use Ecto.Schema
  import Ecto.Changeset

  alias UptimeChecker.Schema.Customer.{Organization, Role, User}

  schema "invitations" do
    field :email, :string
    field :code, :string
    field :expires_at, :utc_datetime
    field :notification_count, :integer

    belongs_to :invited_by, User, foreign_key: :invited_by_user_id

    belongs_to :role, Role
    belongs_to :organization, Organization

    timestamps(type: :utc_datetime)
  end

  def changeset(invitation, attrs) do
    invitation
    |> cast(attrs, [:email, :code, :expires_at, :notification_count])
    |> validate_required([:email, :code, :expires_at])
    |> validate_length(:code, min: 10, max: 100)
    |> unique_constraint(:code)
    |> unique_constraint([:email, :organization_id])
    |> put_assoc(:invited_by, attrs.invited_by)
    |> put_assoc(:role, attrs.role)
    |> put_assoc(:organization, attrs.organization)
  end
end
