defmodule UptimeChecker.Schema.WatchDog.Notification do
  use Ecto.Schema
  import Ecto.Changeset

  alias UptimeChecker.Schema.WatchDog.{Monitor, Alarm}
  alias UptimeChecker.Schema.Customer.{Organization, UserContact}

  @notification_types [raise_alarm: 1, resolve_alarm: 2]

  schema "notifications" do
    field :successful, :boolean, default: true
    field :type, Ecto.Enum, values: @notification_types

    belongs_to :alarm, Alarm
    belongs_to :monitor, Monitor
    belongs_to :user_contact, UserContact
    belongs_to :organization, Organization

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(notification, attrs) do
    notification
    |> cast(attrs, [:successful, :type])
    |> validate_required([:type])
    |> put_assoc(:alarm, attrs.alarm)
    |> put_assoc(:monitor, attrs.monitor)
    |> put_assoc(:user_contact, attrs.user_contact)
    |> put_assoc(:organization, attrs.organization)
  end
end
