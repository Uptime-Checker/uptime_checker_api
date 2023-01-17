defmodule UptimeChecker.Schema.WatchDog.ErrorLog do
  use Ecto.Schema
  import Ecto.Changeset

  alias UptimeChecker.Schema.WatchDog.Check

  @error_types [
    bad_status_code: 1,
    assertion_failure: 2,
    nxdomain: 50,
    etimedout: 51,
    etime: 52,
    erefused: 53,
    epipe: 54,
    enospc: 55,
    enomem: 56,
    enoent: 57,
    enetdown: 58,
    emfile: 59,
    ehostunreach: 60,
    ehostdown: 61,
    econnreset: 62,
    econnrefused: 63,
    econnaborted: 64,
    ecomm: 65,
    timeout: 66,
    ebad: 67
  ]

  schema "error_logs" do
    field :text, :string
    field :status_code, :integer
    field :type, Ecto.Enum, values: @error_types
    field :screenshot_url, :string

    belongs_to :check, Check

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(error_log, attrs) do
    error_log
    |> cast(attrs, [:text, :status_code, :type, :screenshot_url])
    |> validate_required([:text, :status_code, :type])
    |> put_assoc(:check, attrs.check)
    |> put_assoc(:check, attrs.monitor)
  end
end
