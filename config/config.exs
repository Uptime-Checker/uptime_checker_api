# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :uptime_checker,
  ecto_repos: [UptimeChecker.Repo]

# Configures the endpoint
config :uptime_checker, UptimeCheckerWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: UptimeCheckerWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: UptimeChecker.PubSub,
  live_view: [signing_salt: "kLGCLap0"]

# Sentry
config :sentry,
  enable_source_code_context: true,
  root_source_code_path: File.cwd!()

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.29",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time [$level] $message [$metadata]\n",
  metadata: [:module, :file, :function, :line, :request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Guardian for auth
config :uptime_checker, UptimeChecker.Guardian,
  issuer: "uptime_checker",
  secret_key: "J3sSZ0fy5ksV4pNvFD+E7RoLqcxiB3eJii7CwIkmr/BQf8vZGXYzm5pgPNrgZkar"

# Quantum for cron
config :uptime_checker, UptimeChecker.Module.Scheduler,
  jobs: [
    check_monitor: [
      # Every every 10 seconds
      schedule: {:extended, "*/10"},
      task: {UptimeChecker.Cron.CheckMonitor, :work, []},
      run_strategy: {Quantum.RunStrategy.All, :cluster}
    ]
  ]

# Oban for tasks
config :uptime_checker, Oban,
  repo: UptimeChecker.Repo,
  plugins: [
    Oban.Plugins.Pruner,
    {Oban.Plugins.Cron,
     crontab: [
       {"0 * * * *", UptimeChecker.Worker.SyncProductsAsync}
     ]}
  ],
  queues: [default: 100, notification: 100]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
