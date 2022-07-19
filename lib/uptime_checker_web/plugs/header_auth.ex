defmodule UptimeCheckerWeb.Plugs.HeaderAuth do
  import Plug.Conn
  require Logger

  @api_key "X_API_KEY"

  def init(opts), do: opts

  def call(conn, _opts) do
    body = Jason.encode!(%{error: "unauthorized"})
    header_key = List.first(get_req_header(conn, String.downcase(@api_key)))

    unless header_key == System.get_env(@api_key) do
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(:unauthorized, body)
      |> halt()
    else
      conn
    end
  end
end
