defmodule UptimeChecker.Error.HttpError do
  import UptimeChecker.Module.Constant

  const(:unauthorized, "unauthorized")
  const(:not_found, "not_found")
end
