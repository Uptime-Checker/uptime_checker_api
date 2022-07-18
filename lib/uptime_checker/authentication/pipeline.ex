defmodule UptimeChecker.Guardian.AuthPipeline do
  @claims %{typ: "access"}

  use Guardian.Plug.Pipeline,
    otp_app: :todor_api,
    module: UptimeChecker.Guardian,
    error_handler: UptimeChecker.Guardian.AuthErrorHandler

  plug(Guardian.Plug.VerifyHeader, claims: @claims, scheme: "Bearer")
  plug(Guardian.Plug.EnsureAuthenticated)
  plug(Guardian.Plug.LoadResource, ensure: true)
  plug(UptimeChecker.Guardian.CurrentUser)
end
