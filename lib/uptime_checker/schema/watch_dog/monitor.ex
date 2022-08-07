defmodule UptimeChecker.Schema.WatchDog.Monitor do
  use Ecto.Schema
  import Ecto.Changeset

  alias UptimeChecker.Schema.Customer.{Organization, User}
  alias UptimeChecker.Schema.WatchDog.{Check, MonitorRegion}
  alias UptimeChecker.Schema.{Region, StatusCode, MonitorStatusCode}

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
    field :down, :boolean
    field :check_ssl, :boolean
    field :follow_redirects, :boolean

    field :region_threshold, :integer
    field :resolve_threshold, :integer
    field :error_threshold, :integer

    field :last_checked_at, :utc_datetime
    field :last_failed_at, :utc_datetime

    belongs_to :user, User
    belongs_to :organization, Organization

    has_many :checks, Check

    many_to_many :regions, Region, join_through: MonitorRegion, on_replace: :delete
    many_to_many :status_codes, StatusCode, join_through: MonitorStatusCode, on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(monitor, attrs) do
    monitor
    |> cast(attrs, [
      :name,
      :url,
      :method,
      :interval,
      :timeout,
      :body,
      :contains,
      :headers,
      :on,
      :down,
      :check_ssl,
      :follow_redirects,
      :region_threshold,
      :resolve_threshold,
      :error_threshold,
      :last_checked_at,
      :last_failed_at
    ])
    |> validate_required([
      :url,
      :method,
      :interval
    ])
    |> validate_url(:url)
    |> unique_constraint(:url)
    |> validate_inclusion(:interval, 20..86400)
    |> validate_inclusion(:timeout, 1..10)
    |> validate_inclusion(:resolve_threshold, 1..10)
    |> validate_inclusion(:error_threshold, 1..10)
    |> put_assoc(:user, attrs.user)
    |> put_assoc(:organization, attrs.user.organization)
  end

  def update_check_changeset(monitor, attrs) do
    monitor
    |> cast(attrs, [:last_checked_at, :last_failed_at])
    |> validate_required([:last_checked_at])
  end

  def update_alarm_changeset(monitor, attrs) do
    monitor
    |> cast(attrs, [:down])
    |> validate_required([:down])
  end

  def validate_url(changeset, field, options \\ []) do
    validate_change(changeset, field, fn _, url ->
      case UptimeChecker.Http.UrlValidator.cast(url) do
        {:ok, _} -> []
        :error -> [{field, options[:message] || "invalid url: #{inspect(url)}"}]
      end
    end)
  end
end
