defmodule UptimeChecker.Mail.JoinOrg do
  import Bamboo.Email
  use Bamboo.Phoenix, view: UptimeCheckerWeb.EmailView

  alias UptimeChecker.Constant

  def compose(user, invitation) do
    new_email()
    |> from({"[#{Constant.Misc.app_name()} | Invitation]", Constant.Email.no_reply_email_address()})
    |> to(invitation.invited_by.email)
    |> subject("#{user.name} has joined #{invitation.organization.name}")
    |> assign(:invited_by, invitation.invited_by)
    |> assign(:organization, invitation.organization)
    |> assign(:user, user)
    |> assign(:role, invitation.role)
    |> put_html_layout({UptimeCheckerWeb.LayoutView, Constant.Email.layout()})
    |> render(Constant.Email.join_org_template())
  end
end
