defmodule UptimeCheckerWeb.PageController do
  use UptimeCheckerWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
