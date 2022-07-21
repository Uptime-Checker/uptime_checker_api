defmodule UptimeChecker.Repo do
  use Ecto.Repo, otp_app: :uptime_checker, adapter: Ecto.Adapters.Postgres

  require Ecto.Query

  @tenant_key {__MODULE__, :org_id}

  @impl true
  def prepare_query(_operation, query, opts) do
    cond do
      opts[:skip_org_id] || opts[:schema_migration] ->
        {query, opts}

      org_id = opts[:org_id] ->
        {Ecto.Query.where(query, organization_id: ^org_id), opts}

      true ->
        raise "expected org_id or skip_org_id to be set"
    end
  end

  def put_org_id(org_id) do
    Process.put(@tenant_key, org_id)
  end

  def get_org_id() do
    Process.get(@tenant_key)
  end

  @impl true
  def default_options(_operation) do
    [org_id: get_org_id()]
  end
end
