defmodule UptimeCheckerWeb.Plugs.HeaderAuth do
  import Plug.Conn
  require Logger

  @api_key "x_api_key"

  def init(opts), do: opts

  def call(conn, _opts) do
    body = Jason.encode!(%{error: "unauthorized"})

    if get_req_header(conn, @api_key) != System.get_env(@api_key) do
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(:unauthorized, body)
      |> halt()
    end
  end
end
