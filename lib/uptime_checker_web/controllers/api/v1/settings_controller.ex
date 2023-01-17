defmodule UptimeCheckerWeb.Api.V1.SettingsController do
  use UptimeCheckerWeb, :controller

  action_fallback UptimeCheckerWeb.FallbackController

  def status(conn, _params) do
    conn
    |> put_status(:ok)
    |> json(%{status: "ok"})
  end
end
