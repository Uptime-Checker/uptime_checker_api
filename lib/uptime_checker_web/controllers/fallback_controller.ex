defmodule UptimeCheckerWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use UptimeCheckerWeb, :controller

  alias UptimeChecker.Error.HttpError

  # This clause handles errors returned by Ecto's insert/update/delete.
  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(UptimeCheckerWeb.ChangesetView)
    |> render("error.json", changeset: changeset)
  end

  def call(conn, {:error, name, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(UptimeCheckerWeb.ChangesetView)
    |> render("error.json", name: name, changeset: changeset)
  end

  def call(conn, {:error, %ErrorMessage{code: code} = e}) do
    conn
    |> put_status(code)
    |> json(ErrorMessage.to_jsonable_map(e))
  end

  def call(conn, {:error, error}) do
    updated_conn =
      conn
      |> put_view(UptimeCheckerWeb.ErrorView)

    error_string = to_string(error)

    cond do
      String.contains?(error_string, HttpError.not_found()) ->
        updated_conn
        |> put_status(:not_found)
        |> render(:"404", message: error_string)

      String.contains?(error_string, HttpError.unauthorized()) ->
        updated_conn
        |> put_status(:unauthorized)
        |> render(:"401", message: error_string)

      true ->
        updated_conn
        |> put_status(:bad_request)
        |> render(:"400", message: error_string)
    end
  end
end
