defmodule UptimeChecker.Payment do
  import Ecto.Query, warn: false

  alias UptimeChecker.Repo
  alias UptimeChecker.Error.{RepoError, ServiceError}
  alias UptimeChecker.Schema.Payment.{Product, Plan, Subscription, Receipt}

  def create_receipt(attrs) do
    %Receipt{}
    |> Receipt.changeset(attrs)
    |> Repo.insert()
  end

  def create_subscription(attrs) do
    %Receipt{}
    |> Receipt.changeset(attrs)
    |> Repo.insert()
  end

  def get_subscription_by_external_id(id) do
    query = from s in Subscription, where: s.external_id == ^id

    case Repo.one(query) do
      nil -> {:error, RepoError.subscription_not_found() |> ErrorMessage.not_found(%{external_id: id})}
      subscription -> {:ok, subscription}
    end
  end
end
