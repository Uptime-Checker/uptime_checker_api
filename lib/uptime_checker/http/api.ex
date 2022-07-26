defmodule UptimeChecker.Http.Api do
  def hit(url, method, headers, body, timeout, follow_redirect) do
    HTTPoison.start()

    # timeout for establishing a TCP or SSL connection
    # recv_timeout for receiving an HTTP response
    options = [
      timeout: 2000,
      recv_timeout: timeout,
      hackney: [pool: false],
      follow_redirect: follow_redirect,
      max_redirect: 2
    ]

    HTTPoison.request(method, url, body, headers, options)
  end
end
