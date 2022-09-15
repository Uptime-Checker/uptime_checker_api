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
          status: attrs.status,
          paid_at: attrs.paid_at,
          is_trial: attrs.is_trial,
          subscription_id: attrs.subscription_id
        ]
      ],
      conflict_target: :external_id
    )
  end

  def create_subscription(attrs) do
    %Subscription{}
    |> Subscription.changeset(attrs)
    |> Repo.insert(
      on_conflict: [
        set: [
          status: attrs.status,
          is_trial: attrs.is_trial,
          expires_at: attrs.expires_at,
          canceled_at: attrs.canceled_at
        ]
      ],
      conflict_target: :external_id
    )
  end

  def delete_anonymous_subscription(organization_id) do
    query = from s in Subscription, where: s.organization_id == ^organization_id, where: is_nil(s.external_id)
    Repo.delete_all(query)
  end

  def get_subscription_by_external_id(id) do
    query = from s in Subscription, where: s.external_id == ^id

    case Repo.one(query) do
      nil -> {:error, RepoError.subscription_not_found() |> ErrorMessage.not_found(%{external_id: id})}
      subscription -> {:ok, subscription}
    end
  end

  def get_active_subsription_from_user(organization_id) do
    now = Timex.now()

    query =
      from s in Subscription,
        where: s.organization_id == ^organization_id,
        where: s.expires_at > ^now

    case Repo.one(query) do
      nil -> {:error, RepoError.subscription_not_found() |> ErrorMessage.not_found(%{organization_id: organization_id})}
      subscription -> {:ok, subscription}
    end
  end
end
