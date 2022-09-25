defmodule UptimeChecker.Constant.Default do
  import UptimeChecker.Module.Constant

  const(:offset_limit, 20)
  const(:free_duration_in_months, 120)
  const(:trial_duration_in_days, 14)
  const(:payment_method_type, "card")
end
