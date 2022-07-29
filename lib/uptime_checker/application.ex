defmodule UptimeChecker.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    Vapor.load!([%Vapor.Provider.Dotenv{}])

    children = [
      # Start the Ecto repository
      UptimeChecker.Repo,
      # Start the Telemetry supervisor
      UptimeCheckerWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: UptimeChecker.PubSub},
      # Start the Endpoint (http/https)
      UptimeCheckerWeb.Endpoint,
      # Scheduler
      UptimeChecker.Module.Scheduler,
      # Task Supervison
      {Task.Supervisor, name: UptimeChecker.TaskSupervisor},
      # Oban
      {Oban, Application.fetch_env!(:uptime_checker, Oban)}
      # Start a worker by calling: UptimeChecker.Worker.start_link(arg)
      # {UptimeChecker.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: UptimeChecker.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    UptimeCheckerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
