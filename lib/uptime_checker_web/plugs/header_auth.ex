defmodule UptimeCheckerWeb.Plugs.HeaderAuth do
  import Plug.Conn
  alias UptimeChecker.Constant

  def init(opts), do: opts

  def call(conn, _opts) do
    get_req_header(conn, String.downcase(Constant.Env.x_api_key()))
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
    header_key == System.get_env(Constant.Env.x_api_key())
  end
end
