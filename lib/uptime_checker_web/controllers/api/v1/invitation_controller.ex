defmodule UptimeCheckerWeb.Api.V1.InvitationController do
  require Logger

  use Timex
  use UptimeCheckerWeb, :controller

  alias UptimeChecker.Mail
  alias UptimeChecker.Auth
  alias UptimeChecker.Authorization

  alias UptimeChecker.Helper.Strings
  alias UptimeChecker.TaskSupervisors

  alias UptimeChecker.Error.ServiceError
  alias UptimeChecker.Module.{Gandalf, Mailer}
  alias UptimeChecker.Service.InvitationService
  alias UptimeChecker.Schema.Customer.{User, Invitation}

  plug UptimeCheckerWeb.Plugs.Org when action in [:create]

  action_fallback UptimeCheckerWeb.FallbackController

  def create(conn, params) do
    now = Timex.now()
    user = current_user(conn)

    case InvitationService.get_invitation_by_organization(user.organization, params["email"]) do
      {:ok, invitation} ->
        diff = Timex.diff(now, invitation.inserted_at, :minute)

        if diff > 60 do
          create_invitation(conn, params, user)
        else
          {:error, ServiceError.invitation_sent_already() |> ErrorMessage.bad_request(%{remaining: diff})}
        end

      {:error, %ErrorMessage{code: :not_found} = _e} ->
        create_invitation(conn, params, user)
    end
  end

  defp create_invitation(conn, params, user) do
    code = Strings.random_string(15)

    with count <- Authorization.count_users_in_organization(user.organization),
         :ok <- Gandalf.can_send_invitation(user, count),
         {:ok, %Invitation{} = invitation} <- InvitationService.create_invitation(params, user, code) do
      Logger.info("Created new invitation for #{invitation.email} with code: #{code}")

      Mail.Invitation.compose(user, invitation)
      |> Mailer.deliver_later!()

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

      case Auth.get_by_email_with_org_and_role(invitation.email) do
        {:ok, user} ->
          case Authorization.get_organization_user(organization, user) do
            {:ok, _organization_user} ->
              Logger.info("Invited user #{user.id} already exists in the org #{organization.id}")

              with {:ok, updated_user} <- Authorization.update_default_organization_role(user, organization, role) do
                serve_access_token_when_join(conn, invitation, updated_user, false)
              end

            {:error, %ErrorMessage{code: :not_found} = _e} ->
              with {:ok, _organization_user, updated_user} <-
                     Authorization.create_organization_user(user, organization, role) do
                serve_access_token_when_join(conn, invitation, updated_user, true)
              end
          end

        {:error, %ErrorMessage{code: :not_found} = _e} ->
          with {:ok, %User{} = user} <- InvitationService.join_new_user(params, invitation) do
            serve_access_token_when_join(conn, invitation, user, true)
          end
      end
    end
  end

  def serve_access_token_when_join(conn, invitation, user, is_new_user) do
    access_token = after_join_successful(invitation, user)

    if is_new_user do
      Mail.JoinOrg.compose(user, invitation)
      |> Mailer.deliver_later!()
    end

    conn
    |> put_status(:created)
    |> json(%{access_token: access_token})
  end

  defp after_join_successful(invitation, user) do
    Task.Supervisor.start_child(
      {:via, PartitionSupervisor, {TaskSupervisors, self()}},
      InvitationService,
      :delete_invitation,
      [invitation],
      restart: :transient
    )

    {:ok, access_token, _claims} = Auth.encode_and_sign(user)
    access_token
  end
end
