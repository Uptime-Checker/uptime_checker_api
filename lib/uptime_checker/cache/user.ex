defmodule UptimeChecker.Cache.User do
  use Timex

  alias UptimeChecker.Schema.Customer.User

  @cache_user :cache_user

  # =============== User
  def get(user_id) do
    Cachex.get!(@cache_user, get_user_key(user_id))
  end

  def put(user_id, %User{} = user) do
    key = get_user_key(user_id)
    Cachex.put(@cache_user, key, user)
    Cachex.expire(@cache_user, key, :timer.hours(24))
  end

  def clear(user_id) do
    Cachex.clear!(@cache_user, get_user_key(user_id))
  end

  defp get_user_key(user_id), do: "user_#{user_id}"
end
