defmodule UptimeChecker.Helper.Strings do
  def blank?(str) do
    case str do
      nil -> true
      "" -> true
      " " <> r -> blank?(r)
      _ -> false
    end
  end

  def random_string(length) do
    :crypto.strong_rand_bytes(length) |> Base.encode64() |> binary_part(0, length)
  end
end
