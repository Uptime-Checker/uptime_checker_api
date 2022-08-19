defmodule UptimeChecker.Constant.Api do
  import UptimeChecker.Module.Constant

  const(:schema_http, "http")
  const(:schema_https, "https")

  const(:auth_schema, "Bearer")

  const(:content_type_json, "application/json")

  const(:user_agent, "User-Agent")

  const(:google_cert_url, "https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com")
end
