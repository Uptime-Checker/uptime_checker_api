defmodule UptimeCheckerWeb.Api.V1.RegionView do
  use UptimeCheckerWeb, :view
  alias UptimeCheckerWeb.RegionView

  def render("index.json", %{regions: regions}) do
    %{data: render_many(regions, RegionView, "region.json")}
  end

  def render("show.json", %{region: region}) do
    %{data: render_one(region, RegionView, "region.json")}
  end

  def render("region.json", %{region: region}) do
    %{
      id: region.id,
      name: region.name,
      key: region.key,
      ip_address: region.ip_address
    }
  end
end
