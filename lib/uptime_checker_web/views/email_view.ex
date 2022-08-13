defmodule UptimeCheckerWeb.EmailView do
  use UptimeCheckerWeb, :view

  alias UptimeChecker.Constant

  def monitor_status(monitor) do
    down(monitor.down)
  end

  defp down(is_down) when is_down == true, do: Constant.Text.down()
  defp down(is_down) when is_down == false, do: Constant.Text.up()
end
