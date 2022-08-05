#! /bin/sh

mix sentry_recompile && mix compile && mix phx.server