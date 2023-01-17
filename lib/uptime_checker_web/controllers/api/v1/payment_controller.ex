defmodule UptimeCheckerWeb.Api.V1.PaymentController do
  use UptimeCheckerWeb, :controller

  alias UptimeChecker.Payment

  plug UptimeCheckerWeb.Plugs.Org

  action_fallback UptimeCheckerWeb.FallbackController

  def get_active_subscription(conn, _params) do
    user = current_user(conn)

    with {:ok, subscription} <- Payment.get_active_subscription_with_plan_features(user.organization_id) do
      render(conn, "show.json", subscription: subscription)
    end
  end
end
