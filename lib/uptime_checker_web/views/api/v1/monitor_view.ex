defmodule UptimeCheckerWeb.Api.V1.MonitorView do
  use UptimeCheckerWeb, :view

  alias UptimeCheckerWeb.SharedView
  alias UptimeCheckerWeb.Api.V1.MonitorView

  def render("index.json", %{monitors: monitors, meta: meta}) do
    %{data: render_many(monitors, MonitorView, "monitor.json"), meta: SharedView.meta(meta)}
  end

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
      interval: monitor.interval,
      timeout: monitor.timeout,
      body: monitor.body,
      contains: monitor.contains,
      headers: monitor.headers,
      on: monitor.on,
      check_ssl: monitor.check_ssl,
      follow_redirects: monitor.follow_redirects,
      resolve_threshold: monitor.resolve_threshold,
      error_threshold: monitor.error_threshold,
      last_checked_at: monitor.last_checked_at,
      last_failed_at: monitor.last_failed_at,
      prev_id: monitor.prev_id
    }
  end
end
