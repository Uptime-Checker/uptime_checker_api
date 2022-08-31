defmodule UptimeChecker.Constant.Api do
  import UptimeChecker.Module.Constant

  const(:schema_http, "http")
  const(:schema_https, "https")

  const(:auth_schema, "Bearer")

  const(:content_type_json, "application/json")

  const(:user_agent, "User-Agent")

  const(:google_cert_url, "https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com")

  const(:error_host_or_domain_not_found, "Hostname or domain name cannot be found")
  const(:error_connection_timed_out, "Connection timed out")
  const(:error_timer_expired, "Timer expired")
  const(:error_erefused, "EREFUSED")
  const(:error_broken_pipe, "Broken pipe")
  const(:error_no_space_left_on_device, "No space left on device")
  const(:error_not_enough_memory, "Not enough memory")
  const(:error_no_such_file_or_directory, "No such file or directory")
  const(:error_network_is_down, "Network is down")
  const(:error_too_many_open_files, "Too many open files")
  const(:host_or_domain_not_found, "Host is unreachable")
  const(:error_host_is_down, "Host is down")
  const(:error_connection_reset_by_peer, "Connection reset by peer")
  const(:error_connection_refused, "Connection refused")
  const(:error_connection_aborted, "Software caused connection abort")
  const(:error_communication_error_on_send, "Communication error on send")
  const(:error_request_timed_out, "Request timed out")
end
