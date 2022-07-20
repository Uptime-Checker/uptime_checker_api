defmodule UptimeChecker.WatchDog.Check do
  use Ecto.Schema
  import Ecto.Changeset

  schema "checks" do
    field :duration, :float
    field :success, :boolean, default: false

    timestamps()
  end

  @doc false
  def changeset(check, attrs) do
    check
    |> cast(attrs, [:success, :duration])
    |> validate_required([:success, :duration])
  end
end
