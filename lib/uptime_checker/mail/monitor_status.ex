defmodule UptimeChecker.Mail.MonitorStatus do
  import Bamboo.Email
  use Bamboo.Phoenix, view: UptimeCheckerWeb.EmailView

  alias UptimeChecker.Constant

  def compose(monitor, alarm, user_contact) do
    new_email()
    |> from({"[#{Constant.Misc.app_name()} | #{alert(monitor.status)}]", Constant.Email.no_reply_email_address()})
    |> to(user_contact.email)
    |> subject("Monitor is #{down(monitor.status)}: #{monitor.name}")
    |> assign(:monitor, monitor)
    |> assign(:alarm, alarm)
    |> put_html_layout({UptimeCheckerWeb.LayoutView, Constant.Email.layout()})
    |> render(Constant.Email.monitor_status_template())
  end

  defp down(status) when status == :failing, do: Constant.Text.down()
  defp down(status) when status == :passing, do: Constant.Text.up()

  defp alert(status) when status == :failing, do: Constant.Text.alert()
  defp alert(status) when status == :passing, do: Constant.Text.resolved()
end
