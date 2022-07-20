defmodule UptimeCheckerWeb.Api.V1.RegionController do
  use UptimeCheckerWeb, :controller

  alias UptimeChecker.WatchDog
  alias UptimeChecker.Schema.Region

  action_fallback UptimeCheckerWeb.FallbackController

  def index(conn, _params) do
    regions = WatchDog.list_regions()
    render(conn, "index.json", regions: regions)
  end

  def create(conn, %{"region" => region_params}) do
    with {:ok, %Region{} = region} <- WatchDog.create_region(region_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.region_path(conn, :show, region))
      |> render("show.json", region: region)
    end
  end

  def show(conn, %{"id" => id}) do
    region = WatchDog.get_region!(id)
    render(conn, "show.json", region: region)
  end

  def update(conn, %{"id" => id, "region" => region_params}) do
    region = WatchDog.get_region!(id)

    with {:ok, %Region{} = region} <- WatchDog.update_region(region, region_params) do
      render(conn, "show.json", region: region)
    end
  end

  def delete(conn, %{"id" => id}) do
    region = WatchDog.get_region!(id)

    with {:ok, %Region{}} <- WatchDog.delete_region(region) do
      send_resp(conn, :no_content, "")
    end
  end
end
