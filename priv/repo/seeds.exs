# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     UptimeChecker.Repo.insert!(%UptimeChecker.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias UptimeChecker.Authorization
alias UptimeChecker.RegionService

RegionService.create_region(%{name: "Sunnyvale, California (US)", key: "sjc"})
RegionService.create_region(%{name: "Frankfurt, Germany", key: "fra"})
RegionService.create_region(%{name: "Tokyo, Japan", key: "nrt"})
RegionService.create_region(%{name: "Sydney, Australia", key: "syd"})

Authorization.create_role(%{name: "Super Admin", type: :superadmin})
Authorization.create_role(%{name: "Admin", type: :admin})
Authorization.create_role(%{name: "Editor", type: :editor})
Authorization.create_role(%{name: "Member", type: :member})
