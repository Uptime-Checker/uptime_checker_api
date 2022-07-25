defmodule UptimeChecker.Schema.WatchDog.ErrorLog do
  use Ecto.Schema
  import Ecto.Changeset

  alias UptimeChecker.Schema.WatchDog.Check

  schema "error_logs" do
    field :text, :string
    field :status_code, :integer
    field :type, :integer

    belongs_to :check, Check

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(error_log, attrs) do
    error_log
    |> cast(attrs, [:text, :status_code, :type])
    |> validate_required([:text, :status_code, :type])
  end
end
