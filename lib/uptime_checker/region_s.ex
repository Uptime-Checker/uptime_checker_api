defmodule UptimeChecker.Region_S do
  import Ecto.Query, warn: false
  alias UptimeChecker.Repo
  alias UptimeChecker.Schema.Region

  def get_default_region() do
    Region |> Repo.get_by(default: true)
  end

  def list_regions do
    Repo.all(Region)
  end
end
