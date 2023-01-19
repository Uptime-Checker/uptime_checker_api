#! /bin/sh

export FLY_REGION="fra"

mix run priv/repo/seeds.exs
mix run priv/repo/seed_features.exs
mix run priv/repo/seed_accounts.exs