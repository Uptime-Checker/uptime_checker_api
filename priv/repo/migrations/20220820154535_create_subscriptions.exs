defmodule UptimeChecker.Repo.Migrations.CreateSubscriptions do
  use Ecto.Migration

  def change do
    create table(:subscriptions) do
      add :expires_at, :utc_datetime
      add :cancelled_at, :utc_datetime
      add :is_trial, :boolean, default: false
      add :external_id, :string, null: false
      add :external_customer_id, :string

      add :plan_id, references(:plans)
      add :product_id, references(:products)
      add :organization_id, references(:organizations, on_delete: :delete_all)

      timestamps()
    end

    create index(:subscriptions, [:expires_at])
    create unique_index(:subscriptions, [:external_id])

    create index(:subscriptions, [:plan_id])
    create index(:subscriptions, [:product_id])
    create index(:subscriptions, [:organization_id])
  end
end
