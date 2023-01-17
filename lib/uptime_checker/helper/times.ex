defmodule UptimeChecker.Helper.Times do
  use Timex

  def get_duration_in_seconds(from, to) do
    Timex.diff(from, to, :second)
  end

  def human_readable_time_difference(from, to) do
    get_duration_in_seconds(from, to)
    |> Duration.from_seconds()
    |> Timex.Format.Duration.Formatters.Humanized.format()
  end
end
