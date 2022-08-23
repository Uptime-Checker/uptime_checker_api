defmodule UptimeChecker.InvitationService do
  import Ecto.Query, warn: false
  alias UptimeChecker.Repo

  alias UptimeChecker.Auth
  alias UptimeChecker.Helper.Util
  alias UptimeChecker.Authorization
  alias UptimeChecker.Helper.Strings
  alias UptimeChecker.Error.{RepoError, ServiceError}
  alias UptimeChecker.Schema.Customer.{User, UserContact, OrganizationUser, Invitation}

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
    with {:ok, invitation} <- get_invitation_with_org_from_code(code) do
      case Auth.get_by_email_with_org(invitation.email) do
        {:ok, user} ->
          %{invitation: invitation, user: user}

        {:error, %ErrorMessage{code: :not_found} = _e} ->
          %{invitation: invitation}
      end
    end
  end

  def verify_invitation(email, code) do
    now = Timex.now()

    with {:ok, invitation} <- get_invitation_with_org_from_code(code) do
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
      |> Map.put(:role_id, invitation.organization.role.id)
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
      {:ok, %{user: user, user_contact: _user_contact, organization_user: organization_user}} ->
        {:ok, user, organization_user}

      {:error, _name, changeset, _changes_so_far} ->
        {:error, changeset}
    end
  end

  def delete_invitation(%Invitation{} = invitation) do
    Repo.delete(invitation)
  end

  defp get_invitation_with_org_from_code(code) do
    query =
      from invitation in Invitation,
        left_join: o in assoc(invitation, :organization),
        left_join: r in assoc(invitation, :role),
        where: invitation.code == ^code,
        preload: [organization: o, role: r]

    Repo.one(query)
    |> case do
      nil -> {:error, RepoError.invitation_not_found() |> ErrorMessage.not_found(%{code: code})}
      invitation -> {:ok, invitation}
    end
  end
end
