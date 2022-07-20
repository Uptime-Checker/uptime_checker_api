defmodule UptimeChecker.Schema.WatchDog.Monitor do
  use Ecto.Schema
  import Ecto.Changeset

  alias UptimeChecker.Schema.Customer.{Organization, User}
  alias UptimeChecker.Schema.{Region, StatusCode, MonitorRegion, MonitorStatusCode}

  schema "monitors" do
    field :name, :string
    field :url, :string
    field :method, Ecto.Enum, values: [:GET, :POST, :PUT, :DELETE, :PATCH]
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

    belongs_to :user, User
    belongs_to :organization, Organization

    many_to_many :regions, Region, join_through: MonitorRegion, on_replace: :delete
    many_to_many :status_codes, StatusCode, join_through: MonitorStatusCode, on_replace: :delete

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
    |> validate_url(:url)
  end

  def validate_url(changeset, field, options \\ []) do
    validate_change(changeset, field, fn _, url ->
      case url |> String.to_charlist() |> URI.parse() do
        {:ok, _} -> []
        {:error, msg} -> [{field, options[:message] || "invalid url: #{inspect(msg)}"}]
      end
    end)
  end
end
