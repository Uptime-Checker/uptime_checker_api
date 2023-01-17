defmodule UptimeChecker.DailyReport do
  use Timex
  import Ecto.Query, warn: false

  alias UptimeChecker.Repo
  alias UptimeChecker.Schema.DailyReport

  def upsert(monitor, organization, success) do
    today = Timex.today()

    DailyReport
    |> where(monitor_id: ^monitor.id, date: ^today)
    |> update(inc: [successful_checks: ^success_count(success), error_checks: ^error_count(success)])
    |> Repo.update_all([])
    |> case do
      {count, nil} ->
        if count == 0 do
          %DailyReport{}
          |> DailyReport.changeset(%{
            successful_checks: success_count(success),
            error_checks: error_count(success),
            date: today,
            monitor: monitor,
            organization: organization
          })
          |> Repo.insert(
            on_conflict: [inc: [successful_checks: success_count(success), error_checks: error_count(success)]],
            conflict_target: [:date, :monitor_id]
          )
        end
    end
  end

  defp success_count(success) when success == true, do: 1
  defp success_count(success) when success == false, do: 0

  defp error_count(success) when success == true, do: 0
  defp error_count(success) when success == false, do: 1

  def update_duration(monitor, organization, duration) do
    today = Timex.today()

    # We only update downtime when it is resolved
    success = true

    DailyReport
    |> where(monitor_id: ^monitor.id, date: ^today)
    |> update(inc: [downtime: ^duration])
    |> Repo.update_all([])
    |> case do
      {count, nil} ->
        if count == 0 do
          %DailyReport{}
          |> DailyReport.changeset(%{
            successful_checks: success_count(success),
            error_checks: error_count(success),
            date: today,
            downtime: duration,
            monitor: monitor,
            organization: organization
          })
          |> Repo.insert(
            on_conflict: [inc: [successful_checks: success_count(success), error_checks: error_count(success)]],
            conflict_target: [:monitor_id, :date]
          )
        end
    end
  end
end
