defmodule UptimeChecker.Schema.Customer.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias UptimeChecker.Schema.Customer.{Organization, UserContact}

  schema "users" do
    field :email, :string
    field :name, :string
    field :password, :string
    field :firebase_uid, :string
    field :picture_url, :string
    field :last_login_at, :utc_datetime
    field :provider, Ecto.Enum, values: [:email, :google, :apple, :github]

    has_many :user_contacts, UserContact
    belongs_to :organization, Organization

    timestamps(type: :utc_datetime)
  end

  def registration_changeset(user, attrs) do
    provider_registration_changeset(user, attrs)
    |> encrypt_and_put_password()
  end

  def provider_registration_changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :password, :firebase_uid, :provider, :picture_url, :last_login_at])
    |> validate_required([:name, :email, :firebase_uid, :provider])
    |> validate_format(:email, ~r/@/)
    |> validate_length(:name, min: 2, max: 30)
    |> unique_constraint(:email)
    |> unique_constraint(:firebase_uid)
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :password, :firebase_uid, :provider, :organization_id, :last_login_at])
    |> validate_required([:name, :email, :firebase_uid, :provider, :organization_id])
  end

  def update_provider_changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :firebase_uid, :provider, :picture_url])
    |> validate_required([:firebase_uid, :provider])
  end

  defp encrypt_and_put_password(user) do
    with password <- fetch_field!(user, :password) do
      encrypted_password = Bcrypt.Base.hash_password(password, Bcrypt.Base.gen_salt(12, true))
      put_change(user, :password, encrypted_password)
    end
  end
end
