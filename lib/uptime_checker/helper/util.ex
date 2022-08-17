defmodule UptimeChecker.Helper.Util do
  use Timex

  def key_to_atom(map) do
    Enum.reduce(map, %{}, fn
      # String.to_existing_atom saves us from overloading the VM by
      # creating too many atoms. It'll always succeed because all the fields
      # in the database already exist as atoms at runtime.
      {key, value}, acc when is_atom(key) -> Map.put(acc, key, value)
      {key, value}, acc when is_binary(key) -> Map.put(acc, String.to_existing_atom(key), value)
    end)
  end

  def random_string(length) do
    :crypto.strong_rand_bytes(length) |> Base.encode64() |> binary_part(0, length)
  end

  @version Mix.Project.config()[:version]
  def version(), do: @version

  @app Mix.Project.config()[:app]
  def app_name(), do: @app

  def get_duration_in_seconds(from, to) do
    Timex.diff(from, to, :second)
    |> Duration.from_seconds()
  end

  def human_readable_time_difference(from, to) do
    get_duration_in_seconds(from, to)
    |> Timex.Format.Duration.Formatters.Humanized.format()
  end
end
