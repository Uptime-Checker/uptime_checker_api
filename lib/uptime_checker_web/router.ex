defmodule UptimeCheckerWeb.Router do
  use UptimeCheckerWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {UptimeCheckerWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :auth do
    plug UptimeChecker.Guardian.AuthPipeline
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug UptimeCheckerWeb.Plugs.Json
    plug UptimeCheckerWeb.Plugs.HeaderAuth
  end

  scope "/", UptimeCheckerWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  scope "/api", UptimeCheckerWeb.Api, as: :api do
    pipe_through :api

    scope "/v1", V1, as: :v1_open do
      get "/status", SettingsController, :status
      get "/guest_user", UserController, :get_guest_user
      get "/invitation", InvitationController, :get
      get "/external_products", ProductController, :list_external_products
      get "/products", ProductController, :list_products

      post "/register", UserController, :register
      post "/login", UserController, :login
      post "/provider_login", UserController, :provider_login
      post "/guest_user", UserController, :guest_user
      post "/email_link_login", UserController, :email_link_login

      post "/join_new_invitation", InvitationController, :join
    end

    scope "/v1", V1, as: :v1 do
      pipe_through :auth

      get "/me", UserController, :me
      get "/stripe_customer", UserController, :stripe_customer
      get "/get_active_subscription", PaymentController, :get_active_subscription

      resources "/roles", RoleController, only: [:index]
      resources "/organizations", OrganizationController, only: [:create]
      resources "/monitors", MonitorController, only: [:create]
      resources "/invitations", InvitationController, only: [:create]

      post "/monitors/update_order", MonitorController, :update_order
    end
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: UptimeCheckerWeb.Telemetry
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Bamboo.SentEmailViewerPlug
    end
  end
end
