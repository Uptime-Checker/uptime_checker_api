defmodule UptimeChecker.Helper.Util do
  def key_to_atom(map) do
    Enum.reduce(map, %{}, fn
      # String.to_existing_atom saves us from overloading the VM by
      # creating too many atoms. It'll always succeed because all the fields
      # in the database already exist as atoms at runtime.
      {key, value}, acc when is_atom(key) -> Map.put(acc, key, value)
      {key, value}, acc when is_binary(key) -> Map.put(acc, String.to_existing_atom(key), value)
    end)
  end

  @version Mix.Project.config()[:version]
  def version(), do: @version

  @app Mix.Project.config()[:app]
  def app_name(), do: @app
end
