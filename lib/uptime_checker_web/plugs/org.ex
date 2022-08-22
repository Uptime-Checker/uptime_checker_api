defmodule UptimeCheckerWeb.Plugs.Org do
  import Plug.Conn

  alias UptimeChecker.Schema.Customer.User
  alias UptimeChecker.Error.{HttpError, ServiceError}

  def init(opts), do: opts

  def call(conn, _opts) do
    with current_user <- conn.assigns[:current_user] do
      case current_user do
        nil ->
          conn
          |> send_resp(:unauthorized, Jason.encode!(%{error: HttpError.unauthorized()}))
          |> halt()

        %User{} = user ->
          case user.organization_id do
            nil ->
              conn
              |> send_resp(:unauthorized, Jason.encode!(%{error: ServiceError.no_org_found()}))
              |> halt()

            _id ->
              conn
          end
      end
    end
  end
end
