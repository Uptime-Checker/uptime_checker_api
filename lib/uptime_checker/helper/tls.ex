defmodule UptimeChecker.Helper.Tls do
  def check(url) do
    uri = URI.parse(url)
    host = to_charlist(uri.host)
    options = :tls_certificate_check.options(host)
    timeout = 5000
    port = 443

    with {:ok, sock} <- :ssl.connect(host, port, options, timeout),
         {:ok, cert_der} <- :ssl.peercert(sock),
         :ssl.close(sock),
         {:ok, cert} <- X509.Certificate.from_der(cert_der),
         {:Validity, _not_before, not_after} <- X509.Certificate.validity(cert) do
      X509.DateTime.to_datetime(not_after)
    end
  end
end
