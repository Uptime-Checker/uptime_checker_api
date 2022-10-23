defmodule UptimeChecker.Error.ServiceError do
  import UptimeChecker.Module.Constant

  const(:unauthorized, "unauthorized")
  const(:no_org_found, "no organization found")
  const(:email_mismatch, "email mismatch")
  const(:code_expired, "code is expired")

  const(:invitation_sent_already, "invitation is sent already")
  const(:guest_user_link_sent_already, "guest user link is sent already")

  const(:upgrade_permission, "upgrade user's role")
  const(:upgrade_subscription, "upgrade subscription")
end
