defmodule UptimeChecker.Customer.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :firebase_uid, :string
    field :name, :string
    field :password_hash, :string
    field :provider, :integer

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :password_hash, :firebase_uid, :provider])
    |> validate_required([:name, :email, :password_hash, :firebase_uid, :provider])
  end
end
