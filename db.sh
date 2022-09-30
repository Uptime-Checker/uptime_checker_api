#! /bin/sh

mix ecto.setup
mix run priv/repo/seed_features.exs
mix run priv/repo/seed_accounts.exs