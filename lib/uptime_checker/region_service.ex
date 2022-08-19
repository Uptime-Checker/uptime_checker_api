defmodule UptimeChecker.RegionService do
  import Ecto.Query, warn: false
  alias UptimeChecker.Repo
  alias UptimeChecker.Schema.Region

  def get_default_region() do
    Region |> Repo.get_by(default: true)
  end

  def list_regions do
    Repo.all(Region)
  end

  def get_region!(id), do: Repo.get!(Region, id)

  def create_region(attrs \\ %{}) do
    %Region{}
    |> Region.changeset(attrs)
    |> Repo.insert()
  end

  def update_region(%Region{} = region, attrs) do
    region
    |> Region.changeset(attrs)
    |> Repo.update()
  end

  def delete_region(%Region{} = region) do
    Repo.delete(region)
  end
end
