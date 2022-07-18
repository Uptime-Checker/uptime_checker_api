defmodule UptimeChecker.Guardian do
  use Guardian, otp_app: :uptime_checker

  alias UptimeChecker.Customer

  def subject_for_token(user, _claims) do
    {:ok, to_string(user.id)}
  end

  def resource_from_claims(%{"sub" => id}) do
    resource = Customer.get_by_id!(id)
    {:ok, resource}
  end
end
