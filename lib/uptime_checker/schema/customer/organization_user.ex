defmodule UptimeChecker.Schema.Customer.OrganizationUser do
  use Ecto.Schema
  import Ecto.Changeset

  alias UptimeChecker.Schema.Customer.{Organization, User, Role}

  schema "organization_users" do
    belongs_to :user, User
    belongs_to :role, Role
    belongs_to :organization, Organization

    timestamps(type: :utc_datetime)
  end

  def changeset(organization_user, attrs) do
    organization_user
    |> cast(attrs, [])
    |> unique_constraint([:user_id, :organization_id])
    |> put_assoc(:user, attrs.user)
    |> put_assoc(:role, attrs.role)
    |> put_assoc(:organization, attrs.organization)
  end
end
