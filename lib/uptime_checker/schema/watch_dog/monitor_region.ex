defmodule UptimeChecker.Schema.WatchDog.MonitorRegion do
  use Ecto.Schema
  import Ecto.Changeset

  alias UptimeChecker.Schema.Region
  alias UptimeChecker.Schema.WatchDog.Monitor

  schema "monitor_region_junction" do
    field :down, :boolean
    field :last_checked_at, :utc_datetime

    belongs_to(:monitor, Monitor)
    belongs_to(:region, Region)

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(monitor_region, attrs) do
    monitor_region
    |> cast(attrs, [
      :monitor_id,
      :region_id,
      :last_checked_at,
      :down
    ])
    |> unique_constraint([:region_id, :monitor_id])
  end

  @allowed_updates [:last_checked_at, :down]
  def update_changeset(monitor_region, attrs) do
    monitor_region
    |> cast(attrs, @allowed_updates)
    |> validate_required(@allowed_updates)
  end
end
