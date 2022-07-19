defmodule UptimeCheckerWeb.Plugs.Json do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    conn
    |> put_resp_content_type("application/json")
  end
end
