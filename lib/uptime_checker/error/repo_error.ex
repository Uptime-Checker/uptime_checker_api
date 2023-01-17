defmodule UptimeChecker.Error.RepoError do
  import UptimeChecker.Module.Constant

  const(:user_not_found, "user not found")
  const(:role_not_found, "role not found")
  const(:invitation_not_found, "invitation not found")
  const(:guest_user_not_found, "guest user not found")
  const(:user_contact_not_found, "user_contact not found")
  const(:organization_not_found, "organization not found")
  const(:organization_user_not_found, "organization user not found")

  const(:monitor_not_found, "monitor not found")
  const(:monitor_region_not_found, "monitor region not found")
  const(:monitor_user_not_found, "monitor user not found")

  const(:region_not_found, "region not found")

  const(:alarm_not_found, "alarm not found")

  const(:product_not_found, "product not found")
  const(:plan_not_found, "plan not found")
  const(:receipt_not_found, "receipt not found")
  const(:subscription_not_found, "subscription not found")
  const(:feature_not_found, "feature not found")
end
