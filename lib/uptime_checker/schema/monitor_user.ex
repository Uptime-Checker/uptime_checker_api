defmodule UptimeChecker.Schema.MonitorUser do
  use Ecto.Schema
  import Ecto.Changeset

  alias UptimeChecker.Schema.Customer.User
  alias UptimeChecker.Schema.WatchDog.Monitor

  schema "monitor_user_junction" do
    belongs_to :monitor, Monitor
    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(monitor_user, attrs) do
    monitor_user
    |> cast(attrs, [:monitor_id, :user_id])
    |> put_assoc(:monitor, attrs.monitor)
    |> put_assoc(:user, attrs.user)
    |> unique_constraint([:monitor_id, :user_id])
  end
end
