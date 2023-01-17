defmodule UptimeCheckerWeb.SharedView do
  def meta(meta) do
    %{
      after: meta.after,
      before: meta.before,
      limit: meta.limit,
      total_count: meta.total_count,
      total_count_cap_exceeded: meta.total_count_cap_exceeded
    }
  end
end
