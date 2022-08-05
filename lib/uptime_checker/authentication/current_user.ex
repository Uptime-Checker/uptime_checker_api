defmodule UptimeChecker.Guardian.CurrentUser do
  import Plug.Conn
  import Guardian.Plug
  def init(opts), do: opts

  def call(conn, _opts) do
    current_user = current_resource(conn)

    Sentry.Context.set_user_context(%{
      id: current_user.id,
      email: current_user.email
    })

    assign(conn, :current_user, current_user)
  end
end
