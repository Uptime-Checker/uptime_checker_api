defmodule UptimeChecker.Payment do
  import Ecto.Query, warn: false

  alias UptimeChecker.Repo
  alias UptimeChecker.Error.RepoError
  alias UptimeChecker.Schema.Payment.{Subscription, Receipt}

  def create_receipt(attrs) do
    %Receipt{}
    |> Receipt.changeset(attrs)
    |> Repo.insert(
      on_conflict: [
        set: [
          url: attrs.url,
          paid: attrs.paid,
          paid_at: attrs.paid_at,
          status: attrs.status,
          subscription_id: attrs.subscription_id
        ]
      ],
      conflict_target: :external_id
    )
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
