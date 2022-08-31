defmodule UptimeChecker.Event.HandleErrorLog do
  require Logger

  alias UptimeChecker.WatchDog
  alias UptimeChecker.Constant.Api
  alias UptimeChecker.Schema.WatchDog.ErrorLog

  def finalize(tracing_id, reason, check) do
    case reason do
      :nxdomain ->
        create(tracing_id, Api.error_host_or_domain_not_found(), -1, check, :nxdomain)

      :etimedout ->
        create(tracing_id, Api.error_connection_timed_out(), -2, check, :etimedout)

      :etime ->
        create(tracing_id, Api.error_timer_expired(), -3, check, :etime)

      :erefused ->
        create(tracing_id, Api.error_erefused(), -4, check, :erefused)

      :epipe ->
        create(tracing_id, Api.error_broken_pipe(), -5, check, :epipe)

      :enospc ->
        create(tracing_id, Api.error_no_space_left_on_device(), -6, check, :enospc)

      :enomem ->
        create(tracing_id, Api.error_not_enough_memory(), -7, check, :enomem)

      :enoent ->
        create(tracing_id, Api.error_no_such_file_or_directory(), -8, check, :enoent)

      :enetdown ->
        create(tracing_id, Api.error_network_is_down(), -9, check, :enetdown)

      :emfile ->
        create(tracing_id, Api.error_too_many_open_files(), -10, check, :emfile)

      :ehostunreach ->
        create(tracing_id, Api.host_or_domain_not_found(), -11, check, :ehostunreach)

      :ehostdown ->
        create(tracing_id, Api.error_host_is_down(), -12, check, :ehostdown)

      :econnreset ->
        create(tracing_id, Api.error_connection_reset_by_peer(), -13, check, :econnreset)

      :econnrefused ->
        create(tracing_id, Api.error_connection_refused(), -14, check, :econnrefused)

      :econnaborted ->
        create(tracing_id, Api.error_connection_aborted(), -15, check, :econnaborted)

      :ecomm ->
        create(tracing_id, Api.error_communication_error_on_send(), -16, check, :ecomm)

      :timeout ->
        create(tracing_id, Api.error_request_timed_out(), -17, check, :timeout)

      other ->
        create(tracing_id, to_string(other), -1000, check, :ebad)
    end
  end

  def create(tracing_id, text, code, check, type) do
    attrs = %{
      text: text,
      status_code: code,
      type: type
    }

    case WatchDog.create_error_log(attrs, check) do
      {:ok, %ErrorLog{} = error_log} ->
        Logger.debug("#{tracing_id} 1 Created new error log #{error_log.id}")

      {:error, %Ecto.Changeset{} = changeset} ->
        Logger.error("#{tracing_id} 2 Failed to create error log, error: #{inspect(changeset.errors)}")
    end
  end
end
