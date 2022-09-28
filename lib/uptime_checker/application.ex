defmodule UptimeChecker.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    Logger.add_backend(Sentry.LoggerBackend)

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
      # Task Supervisor
      {PartitionSupervisor, child_spec: Task.Supervisor, name: UptimeChecker.TaskSupervisors},
      # Oban
      {Oban, Application.fetch_env!(:uptime_checker, Oban)},
      # Start a worker on startup
      {Task, &UptimeChecker.Event.InitStart.run/0},
      # Caches
      Supervisor.child_spec({Cachex, name: :cache_payment}, id: :cache_payment),
      Supervisor.child_spec({Cachex, name: :cache_stripe_webhook}, id: :cache_stripe_webhook),
      Supervisor.child_spec({Cachex, name: :cache_monitor_region_check}, id: :cache_monitor_region_check)
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
