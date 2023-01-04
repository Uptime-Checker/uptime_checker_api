defmodule UptimeChecker.Schema.WatchDog.Assertion do
  use Ecto.Schema
  import Ecto.Changeset

  alias UptimeChecker.Schema.WatchDog.Monitor

  @sources [status_code: 1, json_body: 2, headers: 3, text_body: 4, response_time: 5]
  @comparisons [
    equals: 1,
    not_equals: 2,
    empty: 3,
    not_empty: 4,
    greater_than: 5,
    less_than: 6,
    contains: 7,
    not_contains: 8,
    null: 9,
    not_null: 10,
    true: 11,
    false: 12
  ]

  schema "assertion" do
    field :source, Ecto.Enum, values: @sources
    field :property, :integer
    field :comparison, Ecto.Enum, values: @comparisons
    field :value, :string

    belongs_to :monitor, Monitor

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(assertion, attrs) do
    assertion
    |> cast(attrs, [:source, :property, :comparison, :value, :monitor_id])
    |> put_assoc(:monitor, attrs.monitor)
    |> unique_constraint([:source, :value, :monitor_id])
  end
end
