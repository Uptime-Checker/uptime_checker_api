defmodule UptimeCheckerWeb.UserView do
  use UptimeCheckerWeb, :view
  alias UptimeCheckerWeb.UserView

  def render("index.json", %{users: users}) do
    %{data: render_many(users, UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{
      id: user.id,
      name: user.name,
      email: user.email,
      password_hash: user.password_hash,
      firebase_uid: user.firebase_uid,
      provider: user.provider
    }
  end
end
