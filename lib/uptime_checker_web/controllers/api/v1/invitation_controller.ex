defmodule UptimeCheckerWeb.Api.V1.InvitationController do
  use UptimeCheckerWeb, :controller

  alias UptimeChecker.Auth
  alias UptimeChecker.TaskSupervisor
  alias UptimeChecker.InvitationService
  alias UptimeChecker.Schema.Customer.{User, Invitation, OrganizationUser}

  plug UptimeCheckerWeb.Plugs.Org when action in [:create]

  action_fallback UptimeCheckerWeb.FallbackController

  def create(conn, params) do
    user = current_user(conn)

    with {:ok, %Invitation{} = invitation} <- InvitationService.create_invitation(params, user.organization) do
      conn
      |> put_status(:created)
      |> render("show.json", invitation: invitation)
    end
  end

  def get(conn, params) do
    case InvitationService.get_invitation_by_code(params["code"]) do
      %{invitation: invitation, user: user} ->
        conn
        |> render("show.json", %{invitation: invitation, user: user})

      %{invitation: invitation} ->
        conn
        |> render("show.json", %{invitation: invitation})
    end
  end

  def join(conn, params) do
    with {:ok, invitation} <- InvitationService.verify_invitation(params["email"], params["code"]) do
      with {:ok, user} <- Auth.get_by_email(invitation.email) do
      else
        {:error, %ErrorMessage{code: :not_found} = _e} ->
          with {:ok, %User{} = user, %OrganizationUser{} = _organization_user} <-
                 InvitationService.join_new_user(params, invitation) do
            access_token = after_join_successful(invitation, user)

            conn
            |> put_status(:created)
            |> json(%{access_token: access_token})
          end
      end
    end
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
