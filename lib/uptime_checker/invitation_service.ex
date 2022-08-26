defmodule UptimeChecker.InvitationService do
  require Logger
  import Ecto.Query, warn: false

  alias UptimeChecker.Repo
  alias UptimeChecker.Auth
  alias UptimeChecker.Helper.Util
  alias UptimeChecker.Authorization
  alias UptimeChecker.Helper.Strings
  alias UptimeChecker.Error.{RepoError, ServiceError}
  alias UptimeChecker.Schema.Customer.{User, UserContact, OrganizationUser, Invitation}

  def create_invitation(attrs \\ %{}, user, code) do
    now = Timex.now()
    later = Timex.shift(now, days: +7)
    hashed_code = code |> Strings.hash_string()

    params = Util.key_to_atom(attrs)
    role = Authorization.get_role!(params[:role_id])

    updated_params =
      params
      |> Map.put(:code, hashed_code)
      |> Map.put(:expires_at, later)
      |> Map.put(:invited_by, user)
      |> Map.put(:role, role)
      |> Map.put(:organization, user.organization)

    %Invitation{}
    |> Invitation.changeset(updated_params)
    |> Repo.insert(
      on_conflict: [set: [code: hashed_code, expires_at: later], inc: [notification_count: 1]],
      conflict_target: [:email, :organization_id]
    )
  end

  def get_invitation_by_code(code) do
    with {:ok, invitation} <- get_invitation_with_org_from_code(Strings.hash_string(code)) do
      case Auth.get_by_email_with_org(invitation.email) do
        {:ok, user} ->
          %{invitation: invitation, user: user}

        {:error, %ErrorMessage{code: :not_found} = _e} ->
          %{invitation: invitation, user: nil}
      end
    end
  end

  def get_invitation_by_organization(organization, email) do
    Invitation
    |> Repo.get_by(email: email, organization_id: organization.id)
    |> case do
      nil -> {:error, RepoError.invitation_not_found() |> ErrorMessage.not_found(%{email: email})}
      invitation -> {:ok, invitation}
    end
  end

  def verify_invitation(email, code) do
    now = Timex.now()

    with {:ok, invitation} <- get_invitation_with_org_from_code(Strings.hash_string(code)) do
      cond do
        invitation.email != email ->
          {:error, ServiceError.email_mismatch() |> ErrorMessage.forbidden(%{email: email})}

        Timex.after?(now, invitation.expires_at) ->
          {:error, ServiceError.code_expired() |> ErrorMessage.bad_request(%{code: code})}

        true ->
          {:ok, invitation}
      end
    end
  end

  def join_new_user(attrs, invitation) do
    user_params =
      Util.key_to_atom(attrs)
      |> Map.put(:role_id, invitation.role.id)
      |> Map.put(:organization_id, invitation.organization.id)

    organization_user_params = %{organization: invitation.organization, role: invitation.role}

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:user, User.join_user_changeset(%User{}, user_params))
    |> Ecto.Multi.run(:user_contact, fn _repo, %{user: user} ->
      user_contact_params = %{email: user.email, mode: :email, verified: true} |> Map.put(:user, user)

      %UserContact{}
      |> UserContact.changeset(user_contact_params)
      |> Repo.insert()
    end)
    |> Ecto.Multi.insert(
      :organization_user,
      fn %{user: user, user_contact: _user_contact} ->
        OrganizationUser.changeset(%OrganizationUser{}, organization_user_params |> Map.put(:user, user))
      end
    )
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user, user_contact: _user_contact, organization_user: _organization_user}} ->
        {:ok, user}

      {:error, name, changeset, _changes_so_far} ->
        Logger.error("Failed to join new user #{inspect(attrs)}, error: #{inspect(changeset.errors)}")
        {:error, name, changeset}
    end
  end

  def delete_invitation(%Invitation{} = invitation) do
    Repo.delete(invitation)
  end

  defp get_invitation_with_org_from_code(code) do
    query =
      from invitation in Invitation,
        left_join: i in assoc(invitation, :invited_by),
        left_join: o in assoc(invitation, :organization),
        left_join: r in assoc(invitation, :role),
        where: invitation.code == ^code,
        preload: [organization: o, role: r, invited_by: i]

    Repo.one(query)
    |> case do
      nil -> {:error, RepoError.invitation_not_found() |> ErrorMessage.not_found(%{code: code})}
      invitation -> {:ok, invitation}
    end
  end
end
