defmodule UptimeChecker.Module.Firebase do
  alias UptimeChecker.Constant.Api

  defp verify!(token) do
    {:ok, 200, _headers, ref} = :hackney.get(Api.google_cert_url())
    {:ok, body} = :hackney.body(ref)
    {:ok, %{"kid" => kid}} = Joken.peek_header(token)

    {true, %{fields: fields}, _} =
      body
      |> Jason.decode!()
      |> JOSE.JWK.from_firebase()
      |> Map.fetch!(kid)
      |> JOSE.JWT.verify(token)

    fields
  end
end
