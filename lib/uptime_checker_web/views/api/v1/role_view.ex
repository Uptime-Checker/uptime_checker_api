defmodule UptimeCheckerWeb.Api.V1.RoleView do
  use UptimeCheckerWeb, :view
  alias UptimeCheckerWeb.Api.V1.RoleView

  def render("index.json", %{roles: roles}) do
    %{data: render_many(roles, RoleView, "role.json")}
  end

  def render("show.json", %{role: role}) do
    %{data: render_one(role, RoleView, "role.json")}
  end

  def render("role.json", %{role: role}) do
    %{
      id: role.id,
      name: role.name,
      type: role.type,
      claims: get_claims(role.claims)
    }
  end

  defp get_claims(claims) when is_list(claims) == true do
    Enum.map(claims, fn claim -> render_claim(claim) end)
  end

  defp get_claims(_claims), do: nil

  defp render_claim(%{:id => _id} = claim) do
    %{
      id: claim.id,
      name: claim.name
    }
  end

  defp render_claim(_claim), do: nil
end
