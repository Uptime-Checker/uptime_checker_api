defmodule UptimeChecker.Error.ServiceError do
  import UptimeChecker.Module.Constant

  const(:unauthorized, "unauthorized")
  const(:no_org_found, "no_org_found")
  const(:email_mismatch, "email_mismatch")
  const(:code_expired, "code_expired")

  const(:invitation_sent_already, "invitation_sent_already")
end
