defmodule UptimeCheckerWeb.Api.V1.PlanView do
  use UptimeCheckerWeb, :view
  alias UptimeCheckerWeb.Api.V1.PlanView

  def render("index.json", %{plans: plans}) do
    %{data: render_many(plans, PlanView, "plan.json")}
  end

  def render("show.json", %{plan: plan}) do
    %{data: render_one(plan, PlanView, "plan.json")}
  end

  def render("plan.json", %{plan: plan}) do
    %{
      id: plan.id,
      price: plan.price,
      type: plan.type,
      product: render_product(plan.product)
    }
  end

  defp render_product(product) do
    %{
      id: product.id,
      name: product.name,
      description: product.description,
      external_id: product.external_id
    }
  end
end
