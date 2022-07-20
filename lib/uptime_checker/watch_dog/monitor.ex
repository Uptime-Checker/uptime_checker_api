defmodule UptimeChecker.WatchDog.Monitor do
  use Ecto.Schema
  import Ecto.Changeset

  schema "monitors" do
    field :name, :string
    field :url, :string
    field :method, Ecto.Enum, values: [:GET, :POST, :PUT, :DELETE, :PATCH]
    field :status_codes, {:array, :integer}
    field :interval, :integer
    field :timeout, :integer

    field :body, :string
    field :contains, :string
    field :headers, :map, default: %{}
    field :on, :boolean
    field :check_ssl, :boolean
    field :follow_redirects, :boolean

    field :resolve_threshold, :integer
    field :error_threshold, :integer

    field :last_checked_at, :utc_datetime
    field :last_failed_at, :utc_datetime
    field :deleted_at, :utc_datetime

    belongs_to :user, UptimeChecker.Customer.User
    belongs_to :organization, UptimeChecker.Customer.Organization

    timestamps()
  end

  @doc false
  def changeset(monitor, attrs) do
    monitor
    |> cast(attrs, [
      :name,
      :url,
      :method,
      :status_codes,
      :interval,
      :timeout,
      :body,
      :contains,
      :headers,
      :on,
      :check_ssl,
      :follow_redirects,
      :resolve_threshold,
      :error_threshold,
      :last_checked_at,
      :last_failed_at,
      :deleted_at
    ])
    |> validate_required([
      :url,
      :method,
      :interval
    ])
  end
end
