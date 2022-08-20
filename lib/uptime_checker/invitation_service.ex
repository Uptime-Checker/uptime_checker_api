defmodule UptimeChecker.InvitationService do
  import Ecto.Query, warn: false
  alias UptimeChecker.Repo

  alias UptimeChecker.Helper.Util
  alias UptimeChecker.Authorization
  alias UptimeChecker.Helper.Strings
  alias UptimeChecker.Schema.Customer.Invitation

  def create_invitation(attrs \\ %{}, organization) do
    now = Timex.now()
    params = Util.key_to_atom(attrs)
    role = Authorization.get_role!(params[:role_id])

    updated_params =
      params
      |> Map.put(:code, Strings.random_string(15))
      |> Map.put(:expires_at, Timex.shift(now, days: +7))
      |> Map.put(:role, role)
      |> Map.put(:organization, organization)

    %Invitation{}
    |> Invitation.changeset(updated_params)
    |> Repo.insert()
  end
end
