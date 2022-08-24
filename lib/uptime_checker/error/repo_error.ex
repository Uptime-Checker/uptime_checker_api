defmodule UptimeChecker.Error.RepoError do
  import UptimeChecker.Module.Constant

  const(:user_not_found, "user_not_found")
  const(:role_not_found, "role_not_found")
  const(:invitation_not_found, "invitation_not_found")
  const(:guest_user_not_found, "guest_user_not_found")
  const(:user_contact_not_found, "user_contact_not_found")
  const(:organization_not_found, "organization_not_found")
  const(:organization_user_not_found, "organization_user_not_found")

  const(:monitor_not_found, "monitor_not_found")
  const(:monitor_region_not_found, "monitor_region_not_found")
  const(:monitor_user_not_found, "monitor_user_not_found")
  const(:monitor_status_code_not_found, "monitor_status_code_not_found")

  const(:region_not_found, "region_not_found")

  const(:alarm_not_found, "alarm_not_found")
end
