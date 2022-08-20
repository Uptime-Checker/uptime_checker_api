defmodule UptimeChecker.InvitationService do
  import Ecto.Query, warn: false
  alias UptimeChecker.Repo

  alias UptimeChecker.Auth
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

  def get_invitation_by_code(code) do
    Invitation
    |> Repo.get_by(code: code)
    |> Repo.preload([:role])
    |> Repo.preload([:organization])
    |> case do
      nil ->
        {:error, :not_found}

      invitation ->
        user = Auth.get_by_email(invitation.email)
        %{invitation: invitation, user: user}
    end
  end

  def verify_invitation(email, code) do
    now = Timex.now()

    Invitation
    |> Repo.get_by(code: code)
    |> case do
      nil ->
        {:error, :not_found}

      invitation ->
        cond do
          invitation.email != email ->
            {:error, :email_mismatch}

          Timex.after?(now, invitation.expires_at) ->
            {:error, :code_expired}

          true ->
            {:ok, invitation}
        end
    end
  end
end
