defmodule UptimeChecker.Schema.Customer.GuestUser do
  use Ecto.Schema
  import Ecto.Changeset

  schema "guest_users" do
    field :email, :string
    field :code, :string
    field :expires_at, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  def changeset(guest_user, attrs) do
    guest_user
    |> cast(attrs, [:email, :code, :expires_at])
    |> validate_required([:email, :code, :expires_at])
    |> validate_length(:code, min: 10, max: 100)
    |> unique_constraint(:code)
  end
end
