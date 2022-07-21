defmodule UptimeChecker.Schema.MonitorRegion do
  use Ecto.Schema

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
end
