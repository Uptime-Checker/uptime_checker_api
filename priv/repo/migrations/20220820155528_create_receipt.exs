defmodule UptimeChecker.Repo.Migrations.CreateReceipt do
  use Ecto.Migration

  def change do
    create table(:receipt) do
      add :price, :float, null: false
      add :currency, :string, default: "usd"
      add :external_id, :string
      add :external_customer_id, :string
      add :url, :string
      add :status, :integer
      add :paid, :boolean, default: false
      add :paid_at, :utc_datetime
      add :from, :date
      add :to, :date
      add :is_trial, :boolean, default: false

      add :plan_id, references(:plan)
      add :product_id, references(:product)
      add :subscription_id, references(:subscription, on_delete: :delete_all)
      add :organization_id, references(:organization, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:receipt, [:external_id])

    create index(:receipt, [:plan_id])
    create index(:receipt, [:product_id])
    create index(:receipt, [:subscription_id])
    create index(:receipt, [:organization_id])
  end
end
