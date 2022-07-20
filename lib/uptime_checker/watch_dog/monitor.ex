defmodule UptimeChecker.WatchDog.Monitor do
  use Ecto.Schema
  import Ecto.Changeset

  schema "monitors" do
    field :body, :string
    field :contains, :string
    field :interval, :integer
    field :last_checked_at, :utc_datetime
    field :last_failed_at, :utc_datetime
    field :method, :integer
    field :name, :string
    field :resolve_threshold, :integer
    field :state, :integer
    field :status_codes, {:array, :integer}
    field :timeout, :integer
    field :url, :string

    timestamps()
  end

  @doc false
  def changeset(monitor, attrs) do
    monitor
    |> cast(attrs, [:name, :url, :method, :status_codes, :interval, :timeout, :last_checked_at, :last_failed_at, :resolve_threshold, :body, :contains, :state])
    |> validate_required([:name, :url, :method, :status_codes, :interval, :timeout, :last_checked_at, :last_failed_at, :resolve_threshold, :body, :contains, :state])
  end
end
