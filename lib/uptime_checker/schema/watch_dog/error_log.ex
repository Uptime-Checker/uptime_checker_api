defmodule UptimeChecker.Schema.WatchDog.ErrorLog do
  use Ecto.Schema
  import Ecto.Changeset

  alias UptimeChecker.Schema.WatchDog.Check

  @error_types [
    status_code_mismatch: 1,
    bad_status_code: 2,
    nxdomain: 3,
    etimedout: 4,
    etime: 5,
    erefused: 6,
    epipe: 7,
    enospc: 8,
    enomem: 9,
    enoent: 10,
    enetdown: 11,
    emfile: 12,
    ehostunreach: 13,
    ehostdown: 14,
    econnreset: 15,
    econnrefused: 16,
    econnaborted: 17,
    ecomm: 18,
    bad: 19
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
  end
end
