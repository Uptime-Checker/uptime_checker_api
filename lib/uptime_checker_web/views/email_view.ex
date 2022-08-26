defmodule UptimeCheckerWeb.EmailView do
  use Timex
  use UptimeCheckerWeb, :view
  alias UptimeChecker.Helper.Times

  alias UptimeChecker.Constant

  def monitor_status(monitor) do
    down(monitor.down)
  end

  def invitation_url(code) do
    "#{System.get_env(Constant.Env.web_url())}#{Constant.Email.join_new_user_url()}/#{code}"
  end

  def changse_role_url(organization) do
    "#{System.get_env(Constant.Env.web_url())}/organization/#{organization.id}/users"
  end

  def format_time(time) do
    time |> Timex.format!("{RFC1123}")
  end

  def difference_between_two_times(from, to) do
    Times.human_readable_time_difference(from, to)
  end

  defp down(is_down) when is_down == true, do: Constant.Text.down()
  defp down(is_down) when is_down == false, do: Constant.Text.up()
end
