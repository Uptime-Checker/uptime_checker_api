defmodule UptimeChecker.Repo do
  use Ecto.Repo, otp_app: :uptime_checker, adapter: Ecto.Adapters.Postgres
  use Quarto, limit: 20
end
