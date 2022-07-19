defmodule UptimeChecker.Guardian do
  use Guardian, otp_app: :uptime_checker

  alias UptimeChecker.Customer

  def subject_for_token(%{id: id}, _claims) do
    {:ok, to_string(id)}
  end

  def subject_for_token(_, _) do
    {:error, :reason_for_error}
  end

  def resource_from_claims(%{"sub" => id}) do
    {:ok, Customer.get_by_id(id)}
  end

  def resource_from_claims(_claims) do
    {:error, :reason_for_error}
  end
end
