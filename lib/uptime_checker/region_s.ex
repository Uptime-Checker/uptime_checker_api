defmodule UptimeChecker.Region_S do
  import Ecto.Query, warn: false
  alias UptimeChecker.Repo
  alias UptimeChecker.Schema.Region

  def get_default_region() do
    Region |> Repo.get_by([default: true], skip_org_id: true)
  end
end
