defmodule UptimeChecker.Repo.Migrations.CreateReceipts do
  use Ecto.Migration

  def change do
    create table(:receipts) do
      add :price, :float, null: false
      add :external_id, :string
      add :paid, :boolean, default: false
      add :paid_at, :utc_datetime
      add :from, :date
      add :to, :date
      add :is_trial, :boolean, default: false

      add :plan_id, references(:plans)
      add :product_id, references(:products)
      add :subscription_id, references(:subscriptions, on_delete: :delete_all)
      add :organization_id, references(:organizations, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:receipts, [:external_id])

    create index(:receipts, [:plan_id])
    create index(:receipts, [:product_id])
    create index(:receipts, [:subscription_id])
    create index(:receipts, [:organization_id])
  end
end
