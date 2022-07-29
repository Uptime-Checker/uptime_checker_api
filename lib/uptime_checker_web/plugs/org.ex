defmodule UptimeCheckerWeb.Plugs.Org do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    case conn.assigns[:current_user].organization_id do
      nil ->
        conn
        |> send_resp(:unauthorized, Jason.encode!(%{error: UptimeChecker.Constant.HttpError.unauthorized()}))
        |> halt()

      _id ->
        conn
    end
  end
end
