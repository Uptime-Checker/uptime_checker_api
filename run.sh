#! /bin/sh

export FLY_REGION="fra"

mix sentry_recompile
mix compile
mix phx.server