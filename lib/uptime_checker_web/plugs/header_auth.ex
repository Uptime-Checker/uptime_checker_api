defmodule UptimeCheckerWeb.Plugs.HeaderAuth do
  import Plug.Conn
  require Logger

  @api_key "X_API_KEY"

  def init(opts), do: opts

  def call(conn, _opts) do
    cond do
      List.first(get_req_header(conn, String.downcase(@api_key))) != System.get_env(@api_key) ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(:unauthorized, Jason.encode!(%{error: "unauthorized"}))
        |> halt()

      true ->
        conn
    end
  end
end
