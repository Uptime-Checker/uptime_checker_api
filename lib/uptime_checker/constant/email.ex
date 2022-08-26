defmodule UptimeChecker.Constant.Email do
  import UptimeChecker.Module.Constant

  const(:layout, "email.html")

  const(:monitor_status_template, "monitor_status.html")
  const(:invitation_template, "invitation.html")

  const(:no_reply_email_address, "no-reply@uptimecheckr.com")
end
