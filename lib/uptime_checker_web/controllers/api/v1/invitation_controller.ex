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
end
