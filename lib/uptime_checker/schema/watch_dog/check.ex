defmodule UptimeChecker.Schema.WatchDog.Check do
  use Ecto.Schema
  import Ecto.Changeset

  alias UptimeChecker.Schema.Region
  alias UptimeChecker.Schema.WatchDog.{Monitor, ErrorLog}

  schema "checks" do
    field :duration, :float
    field :success, :boolean, default: false

    belongs_to :monitor, Monitor
    belongs_to :region, Region

    has_many :error_logs, ErrorLog

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(check, attrs) do
    check
    |> cast(attrs, [:success, :duration])
    |> validate_required([:success, :duration])
  end
end
