defmodule UptimeCheckerWeb.Api.V1.CheckView do
  use UptimeCheckerWeb, :view
  alias UptimeCheckerWeb.Api.V1.CheckView

  def render("index.json", %{checks: checks}) do
    %{data: render_many(checks, CheckView, "check.json")}
  end

  def render("show.json", %{check: check}) do
    %{data: render_one(check, CheckView, "check.json")}
  end

  def render("check.json", %{check: check}) do
    %{
      id: check.id,
      success: check.success,
      duration: check.duration
    }
  end
end
