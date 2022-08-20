defmodule UptimeCheckerWeb.Api.V1.InvitationController do
  use UptimeCheckerWeb, :controller

  alias UptimeChecker.InvitationService
  alias UptimeChecker.Schema.Customer.Invitation

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

  def join(conn, params) do
    with {:ok, invitation} <- InvitationService.verify_invitation(params["email"], params["code"]) do
      with {:ok, user} <- Auth.get_by_email_with_org(invitation.email) do
        access_token = after_email_link_login_successful(guest_user, updated_user)

        conn
        |> put_status(:accepted)
        |> json(%{access_token: access_token})
      else
        {:error, :not_found} ->
          with {:ok, %User{} = user} <- Customer.create_user_for_provider(params) do
            access_token = after_email_link_login_successful(guest_user, user)

            conn
            |> put_status(:created)
            |> json(%{access_token: access_token})
          end
      end
    end
  end

  def get(conn, params) do
    with %{invitation: invitation, user: user} <- InvitationService.get_invitation_by_code(params["code"]) do
      conn
      |> render("show.json", %{invitation: invitation, user: user})
    end
  end

  defp after_email_link_login_successful(guest_user, user) do
    Task.Supervisor.start_child(TaskSupervisor, Auth, :delete_guest_user, [guest_user], restart: :transient)
    {:ok, access_token, _claims} = encode_and_sign(user)
    access_token
  end

  defp encode_and_sign(user) do
    Guardian.encode_and_sign(user, %{}, token_type: "access", ttl: {180, :day})
  end
end
