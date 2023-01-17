defmodule UptimeChecker.Guardian do
  use Guardian, otp_app: :uptime_checker

  alias UptimeChecker.Cache
  alias UptimeChecker.Customer

  def subject_for_token(%{id: id}, _claims) do
    {:ok, to_string(id)}
  end

  def subject_for_token(_, _) do
    {:error, :reason_for_error}
  end

  def resource_from_claims(%{"sub" => id}) do
    cached_user = Cache.User.get(id)

    if is_nil(cached_user) do
      with {:ok, user} <- Customer.get_customer_by_id(id) do
        Cache.User.put(id, user)
        {:ok, user}
      end
    else
      {:ok, cached_user}
    end
  end

  def resource_from_claims(_claims) do
    {:error, :reason_for_error}
  end
end
