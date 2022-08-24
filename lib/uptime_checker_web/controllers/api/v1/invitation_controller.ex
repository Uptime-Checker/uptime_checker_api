defmodule UptimeCheckerWeb.Api.V1.InvitationController do
  require Logger
  use UptimeCheckerWeb, :controller

  alias UptimeChecker.Auth
  alias UptimeChecker.Authorization
  alias UptimeChecker.TaskSupervisor
  alias UptimeChecker.InvitationService
  alias UptimeChecker.Schema.Customer.{User, Invitation}

  plug UptimeCheckerWeb.Plugs.Org when action in [:create]

  action_fallback UptimeCheckerWeb.FallbackController

  def create(conn, params) do
    user = current_user(conn)

    with {:ok, %Invitation{} = invitation} <- InvitationService.create_invitation(params, user.organization) do
      Logger.info("Created new invitation for #{invitation.email} with code: #{invitation.code}")

      conn
      |> put_status(:created)
      |> render("show.json", invitation: invitation)
    end
  end

  def get(conn, params) do
    with %{invitation: invitation, user: user} <- InvitationService.get_invitation_by_code(params["code"]) do
      conn
      |> render("show.json", %{invitation: invitation, user: user})
    end
  end

  def join(conn, params) do
    with {:ok, invitation} <- InvitationService.verify_invitation(params["email"], params["code"]) do
      role = invitation.role
      organization = invitation.organization

      case Auth.get_by_email(invitation.email) do
        {:ok, user} ->
          if is_binary(user.organization) && user.organization.id == organization.id do
            Logger.info("1 Invited user #{user.id} already exists in the org #{organization.id}")
            serve_access_token_when_join(conn, invitation, user)
          else
            case Authorization.get_organization_user(organization, user) do
              {:ok, _organization_user} ->
                Logger.info("2 Invited user #{user.id} already exists in the org #{organization.id}")

                with {:ok, updated_user} <- Authorization.update_default_organization_role(user, organization, role) do
                  serve_access_token_when_join(conn, invitation, updated_user)
                end

              {:error, %ErrorMessage{code: :not_found} = _e} ->
                with {:ok, _organization_user} <-
                       Authorization.create_organization_user(organization, role, user) do
                  serve_access_token_when_join(conn, invitation, user)
                end
            end
          end

        {:error, %ErrorMessage{code: :not_found} = _e} ->
          with {:ok, %User{} = user} <- InvitationService.join_new_user(params, invitation) do
            serve_access_token_when_join(conn, invitation, user)
          end
      end
    end
  end

  def serve_access_token_when_join(conn, invitation, user) do
    access_token = after_join_successful(invitation, user)

    conn
    |> put_status(:created)
    |> json(%{access_token: access_token})
  end

  defp after_join_successful(invitation, user) do
    Task.Supervisor.start_child(
      TaskSupervisor,
      InvitationService,
      :delete_invitation,
      [invitation],
      restart: :transient
    )

    {:ok, access_token, _claims} = Auth.encode_and_sign(user)
    access_token
  end
end
