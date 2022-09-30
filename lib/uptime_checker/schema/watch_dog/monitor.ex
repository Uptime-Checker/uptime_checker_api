defmodule UptimeChecker.Schema.WatchDog.Monitor do
  use Ecto.Schema
  import Ecto.Changeset

  alias UptimeChecker.Schema.Customer.{Organization, User}
  alias UptimeChecker.Schema.WatchDog.{Check, MonitorRegion, Monitor}
  alias UptimeChecker.Schema.{Region, StatusCode, MonitorStatusCode}

  @highest_acceptable_timeout 30

  @body_formats [json: 1, xml: 2, text: 3, html: 4]
  @methods [GET: 1, POST: 2, PUT: 3, PATCH: 4, DELETE: 5, HEAD: 6]

  schema "monitors" do
    field :name, :string
    field :url, :string
    field :method, Ecto.Enum, values: @methods
    field :interval, :integer
    field :timeout, :integer
    field :type, Ecto.Enum, values: [api: 1, browser: 2]

    field :body, :string
    field :body_format, Ecto.Enum, values: @body_formats, default: :json
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
    belongs_to :prev, Monitor, foreign_key: :prev_id

    has_many :checks, Check
    has_many :monitor_regions, MonitorRegion

    many_to_many :regions, Region, join_through: MonitorRegion, on_replace: :delete
    many_to_many :status_codes, StatusCode, join_through: MonitorStatusCode, on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(monitor, attrs) do
    max_timeout = round(attrs.interval / 2)

    max_timeout =
      if max_timeout > @highest_acceptable_timeout do
        @highest_acceptable_timeout
      else
        max_timeout
      end

    monitor
    |> cast(attrs, [
      :name,
      :url,
      :method,
      :interval,
      :timeout,
      :body,
      :body_format,
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
      :last_failed_at,
      :prev_id
    ])
    |> validate_required([:name, :url])
    |> validate_url(:url)
    |> validate_body([:body, :body_format])
    |> unique_constraint([:prev_id, :organization_id])
    |> unique_constraint([:url, :organization_id])
    |> validate_inclusion(:interval, 20..86_400)
    |> validate_inclusion(:timeout, 1..max_timeout)
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

  def update_order_changeset(monitor, attrs) do
    monitor
    |> cast(attrs, [:prev_id])
  end

  def validate_url(changeset, field, options \\ []) do
    validate_change(changeset, field, fn _, url ->
      case UptimeChecker.Http.UrlValidator.cast(url) do
        {:ok, _} -> []
        :error -> [{field, options[:message] || "invalid url: #{inspect(url)}"}]
      end
    end)
  end

  def validate_body(changeset, fields, options \\ []) do
    field = Enum.at(fields, 0)

    validate_change(changeset, field, fn _, body ->
      body_format = get_field(changeset, Enum.at(fields, 1))

      case body_format do
        :json ->
          case Jason.decode(body) do
            {:ok, _} ->
              []

            {:error, %Jason.DecodeError{data: data}} ->
              [{field, options[:message] || "invalid body: #{inspect(data)}"}]
          end

        nil ->
          []
      end
    end)
  end
end
