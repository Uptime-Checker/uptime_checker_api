defmodule UptimeChecker.Schema.WatchDog.Alarm do
  use Ecto.Schema
  import Ecto.Changeset

  alias UptimeChecker.Schema.WatchDog.{Monitor, Check}

  schema "alarms" do
    field :ongoing, :boolean, default: false
    field :resolved_at, :utc_datetime

    belongs_to :triggered_by, Check, foreign_key: :triggered_by_check_id
    belongs_to :resolved_by, Check, foreign_key: :resolved_by_check_id

    belongs_to :monitor, Monitor

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(check, attrs) do
    check
    |> cast(attrs, [:ongoing, :resolved_at])
    |> validate_required([:ongoing, :resolved_at])
  end
end
