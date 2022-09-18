defmodule UptimeChecker.Constant.Claim do
  import UptimeChecker.Module.Constant

  const(:create_resource, "CREATE_RESOURCE")
  const(:update_resource, "UPDATE_RESOURCE")
  const(:delete_resource, "DELETE_RESOURCE")

  const(:billing, "BILLING")

  const(:invite_user, "INVITE_USER")

  const(:destroy_organization, "DESTROY_ORGANIZATION")
end
