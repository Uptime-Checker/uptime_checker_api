defmodule UptimeCheckerWeb.Api.V1.MonitorView do
  use UptimeCheckerWeb, :view
  alias UptimeCheckerWeb.MonitorView

  def render("index.json", %{monitors: monitors}) do
    %{data: render_many(monitors, MonitorView, "monitor.json")}
  end

  def render("show.json", %{monitor: monitor}) do
    %{data: render_one(monitor, MonitorView, "monitor.json")}
  end

  def render("monitor.json", %{monitor: monitor}) do
    %{
      id: monitor.id,
      name: monitor.name,
      url: monitor.url,
      method: monitor.method,
      status_codes: monitor.status_codes,
      interval: monitor.interval,
      timeout: monitor.timeout,
      last_checked_at: monitor.last_checked_at,
      last_failed_at: monitor.last_failed_at,
      resolve_threshold: monitor.resolve_threshold,
      body: monitor.body,
      contains: monitor.contains,
      state: monitor.state
    }
  end
end
