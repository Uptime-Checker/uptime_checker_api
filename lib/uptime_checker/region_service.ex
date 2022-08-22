defmodule UptimeChecker.RegionService do
  import Ecto.Query, warn: false

  alias UptimeChecker.Repo
  alias UptimeChecker.Schema.Region
  alias UptimeChecker.Error.RepoError

  def get_default_region() do
    Region
    |> Repo.get_by(default: true)
    |> case do
      nil -> {:error, RepoError.region_not_found() |> ErrorMessage.not_found(%{default: true})}
      organization -> {:ok, organization}
    end
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
