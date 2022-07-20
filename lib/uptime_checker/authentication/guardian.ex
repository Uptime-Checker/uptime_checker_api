defmodule UptimeChecker.Guardian do
  use Guardian, otp_app: :uptime_checker

  alias UptimeChecker.Customer
  alias UptimeChecker.Repo

  def subject_for_token(%{id: id}, _claims) do
    {:ok, to_string(id)}
  end

  def subject_for_token(_, _) do
    {:error, :reason_for_error}
  end

  def resource_from_claims(%{"sub" => id}) do
    customer = Customer.get_by_id(id)

    case customer do
      %{id: _id} ->
        set_org_id(customer.organization_id)
        {:ok, customer}

      nil ->
        {:error, nil}
    end
  end

  def resource_from_claims(_claims) do
    {:error, :reason_for_error}
  end

  defp set_org_id(nil), do: nil

  defp set_org_id(id) do
    Repo.put_org_id(id)
  end
end
