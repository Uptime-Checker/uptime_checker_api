#! /bin/sh

export FLY_REGION="fra"

mix ecto.setup
mix run priv/repo/seed_features.exs
mix run priv/repo/seed_accounts.exs