defmodule UptimeChecker.Mail.Invitation do
  import Bamboo.Email
  use Bamboo.Phoenix, view: UptimeCheckerWeb.EmailView

  alias UptimeChecker.Constant

  def compose(user, invitation) do
    new_email()
    |> from({"[#{Constant.Misc.app_name()} | Invitation]", Constant.Email.no_reply_email_address()})
    |> to(invitation.email)
    |> subject("You are invited to join #{user.organization.name}")
    |> assign(:user, user)
    |> assign(:invitation, invitation)
    |> put_html_layout({UptimeCheckerWeb.LayoutView, Constant.Email.layout()})
    |> render(Constant.Email.invitation_template())
  end
end
