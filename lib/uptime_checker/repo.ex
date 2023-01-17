defmodule UptimeChecker.Repo do
  alias UptimeChecker.Constant.Default

  use Ecto.Repo, otp_app: :uptime_checker, adapter: Ecto.Adapters.Postgres
  use Quarto, limit: Default.offset_limit()
end
