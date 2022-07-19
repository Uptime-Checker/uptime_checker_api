defmodule UptimeCheckerWeb.Plugs.HeaderAuth do
  import Plug.Conn

  @api_key "X_API_KEY"

  def init(opts), do: opts

  def call(conn, _opts) do
    get_req_header(conn, String.downcase(@api_key))
    |> List.first()
    |> match_key()
    |> case do
      false ->
        conn
        |> send_resp(:unauthorized, Jason.encode!(%{error: "unauthorized"}))
        |> halt()

      true ->
        conn
    end
  end

  defp match_key(header_key) do
    header_key == System.get_env(@api_key)
  end
end
