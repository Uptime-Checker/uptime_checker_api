defmodule UptimeChecker.Constant.Email do
  import UptimeChecker.Module.Constant

  const(:layout, "email.html")

  const(:monitor_status_template, "monitor_status.html")
  const(:invitation_template, "invitation.html")
  const(:join_org_template, "join_org.html")

  const(:no_reply_email_address, "no-reply@uptimecheckr.com")

  const(:join_new_user_url, "/invitation/join_new_user")
end
