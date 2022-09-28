defmodule UptimeChecker.Schema.WatchDog.MonitorStatusChange do
  use Ecto.Schema
  import Ecto.Changeset

  alias UptimeChecker.Schema.WatchDog.Monitor

  @status_types [pending: 1, up: 2, down: 3, paused: 4]

  schema "monitor_status_changes" do
    field :status, Ecto.Enum, values: @status_types
    field :changed_at, :utc_datetime

    belongs_to :monitor, Monitor

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(monitor_status_change, attrs) do
    monitor_status_change
    |> cast(attrs, [:status, :changed_at])
    |> validate_required([:status, :changed_at])
    |> put_assoc(:monitor, attrs.monitor)
    |> unique_constraint([:status, :monitor_id])
  end
end
