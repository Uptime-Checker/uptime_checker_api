defmodule UptimeChecker.DailyReport do
  use Timex
  import Ecto.Query, warn: false

  alias UptimeChecker.Repo
  alias UptimeChecker.Schema.DailyReport

  def upsert(monitor, success) do
    daily_report = DailyReport |> Repo.get_by(monitor_id: monitor.id, date: Timex.today())
    IO.inspect(daily_report)

    case daily_report do
      %DailyReport{} = report ->
        report
        |> DailyReport.check_update_changeset(%{
          successful_checks: success_count(report.successful_checks, success),
          error_checks: error_count(report.error_checks, success)
        })
        |> Repo.update()

      nil ->
        %DailyReport{}
        |> DailyReport.changeset(%{
          successful_checks: success_count(success),
          error_checks: error_count(success),
          date: Timex.today(),
          monitor: monitor
        })
        |> Repo.insert()
    end
  end

  defp success_count(success) when success == true, do: 1
  defp success_count(success) when success == false, do: 0

  defp success_count(successful_checks, success) when success == true, do: successful_checks + 1
  defp success_count(successful_checks, success) when success == false, do: successful_checks

  defp error_count(success) when success == true, do: 0
  defp error_count(success) when success == false, do: 1

  defp error_count(error_checks, success) when success == true, do: error_checks
  defp error_count(error_checks, success) when success == false, do: error_checks + 1
end
