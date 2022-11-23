defmodule UptimeChecker.Helper.Strings do
  @guardian_env Application.compile_env(:uptime_checker, UptimeChecker.Guardian)

  def blank?(str) do
    case str do
      nil -> true
      "" -> true
      " " <> r -> blank?(r)
      _ -> false
    end
  end

  def random_string(length) do
    :crypto.strong_rand_bytes(length) |> Base.url_encode64() |> binary_part(0, length)
  end

  def hash_string(value) do
    secret_key = @guardian_env[:secret_key]
    dbg(secret_key)

    :crypto.mac(:hmac, :sha256, secret_key, value)
    |> Base.encode16()
  end
end
