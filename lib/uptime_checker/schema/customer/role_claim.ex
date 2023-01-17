defmodule UptimeChecker.Schema.Customer.RoleClaim do
  use Ecto.Schema
  import Ecto.Changeset

  alias UptimeChecker.Schema.Customer.{Role, Claim}

  schema "role_claim_junction" do
    belongs_to :role, Role
    belongs_to :claim, Claim

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(role_claim, attrs) do
    role_claim
    |> cast(attrs, [:role_id, :claim_id])
    |> put_assoc(:role, attrs.role)
    |> put_assoc(:claim, attrs.claim)
    |> unique_constraint([:role_id, :claim_id])
  end
end
