defmodule UptimeChecker.Schema.Customer.UserContact do
  use Ecto.Schema
  import Ecto.Changeset

  alias UptimeChecker.Schema.Customer.User

  schema "user_contacts" do
    field :email, :string
    field :number, :string
    field :device_id, :string
    field :verified, :boolean, default: false
    field :mode, Ecto.Enum, values: [email: 1, sms: 2, phone: 3]

    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  def changeset(user_contact, attrs) do
    user_contact
    |> cast(attrs, [:email, :number, :device_id, :verified, :mode])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint([:email, :verified])
    |> unique_constraint([:number, :verified])
    |> unique_constraint(:device_id)
    |> put_assoc(:user, attrs.user)
  end
end
