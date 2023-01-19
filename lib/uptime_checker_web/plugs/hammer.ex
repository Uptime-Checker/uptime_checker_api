defmodule UptimeCheckerWeb.Plugs.Hammer do
  import Plug.Conn

  alias UptimeChecker.Error.HttpError

  def init(opts), do: opts

  def call(conn, _opts) do
    ip = to_string(:inet_parse.ntoa(conn.remote_ip))
    dbg(ip)

    case Hammer.check_rate("session:#{ip}", 60_000, 10) do
      {:allow, _count} ->
        conn

      {:deny, _limit} ->
        conn
        |> send_resp(:too_many_requests, Jason.encode!(%{error: HttpError.too_many_requests()}))
        |> halt()
    end
  end
end
