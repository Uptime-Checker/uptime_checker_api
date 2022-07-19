defmodule UptimeCheckerWeb.ControllerHelper do
  def current_user(conn) do
    conn.assigns[:current_user]
  end

  @spec name_from_email(String.t()) :: String.t()
  def name_from_email(email) do
    email |> String.split("@") |> hd()
  end
end
