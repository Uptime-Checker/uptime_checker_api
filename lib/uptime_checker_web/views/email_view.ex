defmodule UptimeCheckerWeb.EmailView do
  use Timex
  use UptimeCheckerWeb, :view
  alias UptimeChecker.Helper.Times

  alias UptimeChecker.Constant

  def monitor_status(monitor) do
    down(monitor.status)
  end

  def invitation_url(code) do
    "#{System.get_env(Constant.Env.web_url())}#{Constant.Email.join_new_user_url()}/#{code}"
  end

  def change_role_url(organization) do
    "#{System.get_env(Constant.Env.web_url())}/organization/#{organization.id}/users"
  end

  def format_time(time) do
    time |> Timex.format!("{RFC1123}")
  end

  def difference_between_two_times(from, to) do
    Times.human_readable_time_difference(from, to)
  end

  defp down(monitor_status) when monitor_status == :failing, do: Constant.Text.down()
  defp down(monitor_status) when monitor_status == :passing, do: Constant.Text.up()
end
