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

  const(:product_not_found, "product_not_found")
  const(:plan_not_found, "plan_not_found")
  const(:receipt_not_found, "receipt_not_found")
  const(:subscription_not_found, "subscription_not_found")
  const(:feature_not_found, "feature_not_found")
end
