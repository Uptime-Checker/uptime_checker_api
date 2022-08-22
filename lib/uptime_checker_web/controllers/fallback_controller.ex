defmodule UptimeCheckerWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use UptimeCheckerWeb, :controller

  # This clause handles errors returned by Ecto's insert/update/delete.
  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(UptimeCheckerWeb.ChangesetView)
    |> render("error.json", changeset: changeset)
  end

  def call(conn, {:error, error}) do
    updated_conn =
      conn
      |> put_view(UptimeCheckerWeb.ErrorView)

    error_string = to_string(error)

    if String.contains?(error_string, "not_found") do
      updated_conn
      |> put_status(:bad_request)
      |> render(:"400", message: error_string)
    else
      updated_conn
      |> put_status(:not_found)
      |> render(:"404", message: error_string)
    end
  end
end
