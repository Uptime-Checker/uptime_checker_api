defmodule UptimeChecker.Schema.Customer.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :name, :string
    field :password, :string
    field :firebase_uid, :string
    field :provider, Ecto.Enum, values: [:email, :google, :apple, :github]

    belongs_to :organization, UptimeChecker.Customer.Organization

    timestamps()
  end

  def registration_changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :password, :firebase_uid, :provider])
    |> validate_required([:name, :email, :firebase_uid, :provider])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
    |> unique_constraint(:firebase_uid)
    |> encrypt_and_put_password()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :password, :firebase_uid, :provider, :organization_id])
    |> validate_required([:name, :email, :firebase_uid, :provider, :organization_id])
  end

  defp encrypt_and_put_password(user) do
    with password <- fetch_field!(user, :password) do
      encrypted_password = Bcrypt.Base.hash_password(password, Bcrypt.Base.gen_salt(12, true))
      put_change(user, :password, encrypted_password)
    end
  end
end
