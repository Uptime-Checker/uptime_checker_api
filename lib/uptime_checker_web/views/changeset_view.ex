defmodule UptimeCheckerWeb.ChangesetView do
  use UptimeCheckerWeb, :view

  def format_changeset_errors(%Ecto.Changeset{} = changeset) do
    translate_errors(changeset)
    |> Enum.map(fn {key, value} ->
      {to_string(key), Enum.at(value, 0)}
    end)
  end

  @doc """
  Traverses and translates changeset errors.

  See `Ecto.Changeset.traverse_errors/2` and
  `UptimeCheckerWeb.ErrorHelpers.translate_error/1` for more details.
  """
  def translate_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
  end

  def render("error.json", %{changeset: changeset}) do
    # When encoded, the changeset returns its errors
    # as a JSON object. So we just pass it forward.
    %{errors: translate_errors(changeset)}
  end
end
