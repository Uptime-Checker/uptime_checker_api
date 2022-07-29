defmodule UptimeChecker.Http.Api do
  require Logger

  def hit(tracing_id, url, method, headers, body, timeout, follow_redirect) do
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

    Logger.info("#{tracing_id} Hitting => #{url}")
    HTTPoison.request(method, url, body, headers, options)
  end
end
