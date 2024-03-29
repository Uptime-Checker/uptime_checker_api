defmodule UptimeChecker.Guardian.AuthPipeline do
  @claims %{typ: "access"}

  use Guardian.Plug.Pipeline,
    otp_app: :uptime_checker,
    module: UptimeChecker.Guardian,
    error_handler: UptimeChecker.Guardian.AuthErrorHandler

  plug(Guardian.Plug.VerifyHeader, claims: @claims, scheme: UptimeChecker.Constant.Api.auth_schema())
  plug(Guardian.Plug.EnsureAuthenticated)
  plug(Guardian.Plug.LoadResource, ensure: true)
  plug(UptimeChecker.Guardian.CurrentUser)
end
