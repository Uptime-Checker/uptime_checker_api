# mix run priv/repo/seed_accounts.exs

alias UptimeChecker.Constant
alias UptimeChecker.Authorization

# Roles
superadmin_role = Authorization.get_role_by_type!(:superadmin)
admin_role = Authorization.get_role_by_type!(:admin)
editor_role = Authorization.get_role_by_type!(:editor)

# Claims
{:ok, create_resource_claim} = Authorization.create_claim(%{name: Constant.Claim.create_resource()})
{:ok, update_resource_claim} = Authorization.create_claim(%{name: Constant.Claim.update_resource()})
{:ok, delete_resource_claim} = Authorization.create_claim(%{name: Constant.Claim.delete_resource()})

{:ok, billing_claim} = Authorization.create_claim(%{name: Constant.Claim.billing()})

{:ok, invite_user_claim} = Authorization.create_claim(%{name: Constant.Claim.invite_user()})

{:ok, destroy_organization_claim} = Authorization.create_claim(%{name: Constant.Claim.destroy_organization()})

# Role Claims
Authorization.create_role_claim(%{role: superadmin_role, claim: create_resource_claim})
Authorization.create_role_claim(%{role: superadmin_role, claim: update_resource_claim})
Authorization.create_role_claim(%{role: superadmin_role, claim: delete_resource_claim})
Authorization.create_role_claim(%{role: superadmin_role, claim: billing_claim})
Authorization.create_role_claim(%{role: superadmin_role, claim: invite_user_claim})
Authorization.create_role_claim(%{role: superadmin_role, claim: destroy_organization_claim})

Authorization.create_role_claim(%{role: admin_role, claim: create_resource_claim})
Authorization.create_role_claim(%{role: admin_role, claim: update_resource_claim})
Authorization.create_role_claim(%{role: admin_role, claim: delete_resource_claim})
Authorization.create_role_claim(%{role: admin_role, claim: invite_user_claim})

Authorization.create_role_claim(%{role: editor_role, claim: create_resource_claim})
Authorization.create_role_claim(%{role: editor_role, claim: update_resource_claim})
Authorization.create_role_claim(%{role: editor_role, claim: delete_resource_claim})
