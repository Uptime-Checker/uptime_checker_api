defmodule UptimeChecker.Schema.WatchDog.Alarm do
  use Ecto.Schema
  import Ecto.Changeset

  alias UptimeChecker.Schema.Customer.Organization
  alias UptimeChecker.Schema.WatchDog.{Monitor, Check}

  schema "alarms" do
    field :ongoing, :boolean, default: false
    field :resolved_at, :utc_datetime

    belongs_to :triggered_by, Check, foreign_key: :triggered_by_check_id
    belongs_to :resolved_by, Check, foreign_key: :resolved_by_check_id

    belongs_to :monitor, Monitor
    belongs_to :organization, Organization

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(alarm, attrs) do
    alarm
    |> cast(attrs, [:ongoing])
    |> validate_required([:ongoing])
    |> put_assoc(:monitor, attrs.monitor)
    |> put_assoc(:triggered_by, attrs.check)
    |> put_assoc(:organization, attrs.organization)
    |> unique_constraint([:ongoing], name: :uq_monitor_on_alarm)
  end

  def resolve_changeset(alarm, attrs) do
    alarm
    |> cast(attrs, [:ongoing, :resolved_at])
    |> validate_required([:ongoing, :resolved_at])
    |> put_assoc(:resolved_by, attrs.check)
  end
end
