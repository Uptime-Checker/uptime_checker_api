defmodule UptimeChecker.CustomerFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `UptimeChecker.Customer` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        email: "some email",
        provider_uid: "some provider_uid",
        name: "some name",
        password_hash: "some password_hash",
        provider: 42
      })
      |> UptimeChecker.Customer.create_user()

    user
  end
end
