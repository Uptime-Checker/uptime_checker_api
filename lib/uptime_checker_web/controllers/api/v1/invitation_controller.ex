defmodule UptimeCheckerWeb.Api.V1.InvitationController do
  use UptimeCheckerWeb, :controller

  alias UptimeChecker.InvitationService
  alias UptimeChecker.Schema.Customer.Invitation

  plug UptimeCheckerWeb.Plugs.Org

  action_fallback UptimeCheckerWeb.FallbackController

  def create(conn, params) do
    user = current_user(conn)

    with {:ok, %Invitation{} = invitation} <- InvitationService.create_invitation(params, user.organization) do
      conn
      |> put_status(:created)
      |> render("show.json", invitation: invitation)
    end
  end
end
