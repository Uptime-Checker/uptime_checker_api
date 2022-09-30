defmodule UptimeChecker.Http.Api do
  require Logger

  alias UptimeChecker.Constant
  alias UptimeChecker.Helper.Util

  def hit(tracing_id, url, method, headers, body, body_format, timeout, follow_redirect) do
    HTTPoison.start()

    # timeout for establishing a TCP or SSL connection
    # recv_timeout for receiving an HTTP response
    options = [
      timeout: 3000,
      recv_timeout: timeout * 1000,
      hackney: [pool: false],
      follow_redirect: follow_redirect,
      max_redirect: 2
    ]

    headers_with_agent =
      headers
      |> Map.put(Constant.Api.user_agent(), "#{Util.app_name()}_agent/#{Util.version()}")
      |> Map.put(Constant.Api.content_type(), get_content_type(body_format))

    Logger.info("#{tracing_id} Hitting => #{url}")
    HTTPoison.request(method, url, body, headers_with_agent, options)
  end

  defp get_content_type(_body_format) do
    Constant.Api.content_type_json()
  end
end
