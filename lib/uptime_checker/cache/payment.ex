defmodule UptimeChecker.Cache.Payment do
  @cache_name :payment

  def get(key) do
    Cachex.get!(@cache_name, key)
  end

  def put(key, data) do
    Cachex.put(@cache_name, key, data)
    Cachex.expire(@cache_name, key, :timer.minutes(60))
  end
end
