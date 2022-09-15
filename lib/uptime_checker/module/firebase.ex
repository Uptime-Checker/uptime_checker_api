defmodule UptimeChecker.Module.Firebase do
  use Timex
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

  def verify_id_token!(token) do
    now = Timex.now()
    fields = verify!(token)
    expires_at = fields["exp"] |> Timex.from_unix()

    cond do
      fields["iss"] != System.get_env("FIREBASE_ISSUER") ->
        {:error, :issuer_mismatch}

      Timex.after?(now, expires_at) ->
        {:error, :token_expired}

      true ->
        {:ok,
         %{
           name: fields["name"],
           email: fields["email"],
           picture_url: fields["picture"],
           firebase_uid: fields["user_id"]
         }}
    end
  end
end
