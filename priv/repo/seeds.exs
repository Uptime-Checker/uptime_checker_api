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
alias UptimeChecker.Region_S

Region_S.create_region(%{name: "Sunnyvale, California (US)", key: "sjc"})
Region_S.create_region(%{name: "Frankfurt, Germany", key: "fra"})
