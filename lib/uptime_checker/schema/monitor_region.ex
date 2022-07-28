defmodule UptimeChecker.Schema.MonitorRegion do
  use Ecto.Schema
  import Ecto.Changeset

  alias UptimeChecker.Schema.Region
  alias UptimeChecker.Schema.WatchDog.Monitor

  schema "monitor_region_junction" do
    field :last_checked_at, :utc_datetime
    field :next_check_at, :utc_datetime
    field :consequtive_failure, :integer
    field :consequtive_recovery, :integer

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
      :next_check_at,
      :consequtive_failure,
      :consequtive_recovery
    ])
  end

  def update_check_changeset(monitor_region, attrs) do
    monitor_region
    |> cast(attrs, [:last_checked_at, :next_check_at])
    |> validate_required([:last_checked_at, :next_check_at])
  end
end
