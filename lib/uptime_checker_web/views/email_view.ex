defmodule UptimeCheckerWeb.EmailView do
  use Timex
  use UptimeCheckerWeb, :view
  alias UptimeChecker.Helper.Util

  alias UptimeChecker.Constant

  def monitor_status(monitor) do
    down(monitor.down)
  end

  def format_time(time) do
    time |> Timex.format!("{RFC1123}")
  end

  def difference_between_two_times(from, to) do
    Util.human_readable_time_difference(from, to)
  end

  defp down(is_down) when is_down == true, do: Constant.Text.down()
  defp down(is_down) when is_down == false, do: Constant.Text.up()
end