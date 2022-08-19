defmodule UptimeCheckerWeb.Api.V1.RegionController do
  use UptimeCheckerWeb, :controller

  alias UptimeChecker.Schema.Region
  alias UptimeChecker.Region_Service

  action_fallback UptimeCheckerWeb.FallbackController

  def index(conn, _params) do
    regions = Region_Service.list_regions()
    render(conn, "index.json", regions: regions)
  end

  def create(conn, %{"region" => region_params}) do
    with {:ok, %Region{} = region} <- Region_Service.create_region(region_params) do
      conn
      |> put_status(:created)
      |> render("show.json", region: region)
    end
  end

  def show(conn, %{"id" => id}) do
    region = Region_Service.get_region!(id)
    render(conn, "show.json", region: region)
  end

  def update(conn, %{"id" => id, "region" => region_params}) do
    region = Region_Service.get_region!(id)

    with {:ok, %Region{} = region} <- Region_Service.update_region(region, region_params) do
      render(conn, "show.json", region: region)
    end
  end

  def delete(conn, %{"id" => id}) do
    region = Region_Service.get_region!(id)

    with {:ok, %Region{}} <- Region_Service.delete_region(region) do
      send_resp(conn, :no_content, "")
    end
  end
end
