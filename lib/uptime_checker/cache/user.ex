defmodule UptimeChecker.Cache.User do
  use Timex

  alias UptimeChecker.Constant
  alias UptimeChecker.Schema.Customer.User

  @cache_user :cache_user

  # =============== User
  def get(user_id) do
    Cachex.get!(@cache_user, get_user_key(user_id))
  end

  def put(user_id, %User{} = user) do
    key = get_user_key(user_id)
    Cachex.put(@cache_user, key, user)
    Cachex.expire(@cache_user, key, :timer.hours(7 * 24))
  end

  def bust(user_id) do
    clear(user_id)
    clear_organizations(user_id)
    clear_full_info(user_id)
  end

  defp clear(user_id) do
    Cachex.clear!(@cache_user, get_user_key(user_id))
  end

  defp get_user_key(user_id), do: "user_#{user_id}"

  # =============== Roles
  def get_roles() do
    Cachex.get!(@cache_user, Constant.Cache.roles())
  end

  def put_roles(roles) do
    Cachex.put(@cache_user, Constant.Cache.roles(), roles)
    Cachex.expire(@cache_user, Constant.Cache.roles(), :timer.hours(30 * 24))
  end

  # =============== Organizations
  def get_organizations(user_id) do
    Cachex.get!(@cache_user, get_organizations_key(user_id))
  end

  def put_organizations(user_id, organizations) do
    Cachex.put(@cache_user, get_organizations_key(user_id), organizations)
    Cachex.expire(@cache_user, get_organizations_key(user_id), :timer.hours(30 * 24))
  end

  defp clear_organizations(user_id) do
    Cachex.clear!(@cache_user, get_organizations_key(user_id))
  end

  defp get_organizations_key(user_id), do: "user_#{user_id}_organizations"

  # =============== Full Info
  def get_full_info(user_id) do
    Cachex.get!(@cache_user, get_full_info_key(user_id))
  end

  def put_full_info(user_id, %{user: user, subscription: subscription, organization_users: organization_users}) do
    Cachex.put(@cache_user, get_full_info_key(user_id), %{
      user: user,
      subscription: subscription,
      organization_users: organization_users
    })

    Cachex.expire(@cache_user, get_full_info_key(user_id), :timer.hours(30 * 24))
  end

  defp clear_full_info(user_id) do
    Cachex.clear!(@cache_user, get_full_info_key(user_id))
  end

  defp get_full_info_key(user_id), do: "user_#{user_id}_full_info"
end
