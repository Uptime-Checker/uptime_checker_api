defmodule UptimeCheckerWeb.Api.V1.OrganizationController do
  use UptimeCheckerWeb, :controller

  alias UptimeChecker.Customer
  alias UptimeChecker.ProductService
  alias UptimeChecker.TaskSupervisors
  alias UptimeChecker.Schema.Customer.Organization

  action_fallback UptimeCheckerWeb.FallbackController

  def create(conn, params) do
    user = current_user(conn)

    with {:ok, plan} <- ProductService.get_plan_with_product(params["plan_id"]),
         {:ok, %Organization{} = organization} <- Customer.create_organization(params, user) do
      Task.Supervisor.start_child(
        {:via, PartitionSupervisor, {TaskSupervisors, self()}},
        fn ->
          {:ok, updated_user} = UptimeChecker.Module.Stripe.User.create_stripe_customer(user)
          UptimeChecker.Module.Stripe.Billing.create_subscription(updated_user, plan, is_trial(plan))
        end,
        restart: :transient
      )

      conn
      |> put_status(:created)
      |> render("show.json", %{organization: organization})
    end
  end

  defp is_trial(plan) when plan.product.tier == :free, do: false
  defp is_trial(_plan), do: true
end
