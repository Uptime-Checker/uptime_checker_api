defmodule UptimeChecker.Error.HttpError do
  import UptimeChecker.Module.Constant

  const(:unauthorized, "unauthorized")
  const(:not_found, "not found")
  const(:forbidden, "forbidden")
  const(:too_many_requests, "too many requests")
end
