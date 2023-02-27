defmodule UptimeChecker.Repo.Migrations.CreateSubscription do
  use Ecto.Migration

  def change do
    create table(:subscription) do
      add :status, :integer
      add :starts_at, :utc_datetime
      add :expires_at, :utc_datetime
      add :canceled_at, :utc_datetime
      add :is_trial, :boolean, default: false
      add :external_id, :string
      add :external_customer_id, :string

      add :plan_id, references(:plan)
      add :product_id, references(:product)
      add :organization_id, references(:organization, on_delete: :delete_all)

      timestamps()
    end

    create index(:subscription, [:status])
    create index(:subscription, [:expires_at])
    create unique_index(:subscription, [:external_id])

    create index(:subscription, [:plan_id])
    create index(:subscription, [:product_id])
    create index(:subscription, [:organization_id])
  end
end
