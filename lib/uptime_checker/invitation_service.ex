defmodule UptimeChecker.InvitationService do
  import Ecto.Query, warn: false
  alias UptimeChecker.Repo

  alias UptimeChecker.Helper.Util
  alias UptimeChecker.Authorization
  alias UptimeChecker.Helper.Strings
  alias UptimeChecker.Schema.Customer.{User, Invitation}

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
    invitation_query =
      from invitation in Invitation,
        left_join: o in assoc(invitation, :organization),
        where: invitation.code == ^code,
        preload: [organization: o]

    Repo.one(invitation_query)
    |> case do
      nil ->
        {:error, :not_found}

      invitation ->
        user_query =
          from user in User,
            left_join: o in assoc(user, :organization),
            where: user.email == ^invitation.email,
            preload: [organization: o]

        user = Repo.one(user_query)
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
