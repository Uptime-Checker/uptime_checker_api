defmodule UptimeChecker.Mail.MonitorStatus do
  import Bamboo.Email
  use Bamboo.Phoenix, view: UptimeCheckerWeb.EmailView

  alias UptimeChecker.Constant

  def compose(monitor, alarm, user_contact) do
    new_email()
    |> from({"[#{Constant.Misc.app_name()} | #{alert(monitor.down)}]", Constant.Email.no_reply_email_address()})
    |> to(user_contact.email)
    |> subject("Monitor is #{down(monitor.down)}: #{monitor.name}")
    |> assign(:monitor, monitor)
    |> assign(:alarm, alarm)
    |> put_html_layout({UptimeCheckerWeb.LayoutView, Constant.Email.layout()})
    |> render(Constant.Email.monitor_status_template())
  end

  defp down(is_down) when is_down == true, do: Constant.Text.down()
  defp down(is_down) when is_down == false, do: Constant.Text.up()

  defp alert(is_down) when is_down == true, do: Constant.Text.alert()
  defp alert(is_down) when is_down == false, do: Constant.Text.resolved()
end
