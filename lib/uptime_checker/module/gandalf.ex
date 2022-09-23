defmodule UptimeChecker.Module.Gandalf do
  alias UptimeChecker.Payment
  alias UptimeChecker.Constant
  alias UptimeChecker.Error.ServiceError
  alias UptimeChecker.Schema.Customer.User

  def can_send_invitation(%User{} = user, count) do
    with :ok <- handle_claim(user, Constant.Claim.create_resource()),
         :ok <- handle_claim(user, Constant.Claim.invite_user()) do
      handle_feature_max(user, Constant.Feature.user_count(), :team, count + 1)
    end
  end

  def can_create_monitor(%User{} = user, count, interval) do
    with :ok <- handle_claim(user, Constant.Claim.create_resource()),
         :ok <- handle_feature_max(user, Constant.Feature.api_check_count(), :monitoring, count + 1) do
      handle_feature_min(user, Constant.Feature.api_check_interval(), :monitoring, interval)
    end
  end

  def can_update_resource(%User{} = user) do
    handle_claim(user, Constant.Claim.update_resource())
  end

  def can_delete_resource(%User{} = user) do
    handle_claim(user, Constant.Claim.delete_resource())
  end

  defp handle_feature_max(%User{} = user, feature_name, feature_type, count) do
    case feature(user, feature_name, feature_type) do
      %{count: max_count} ->
        if count <= max_count do
          :ok
        else
          {:error,
           ServiceError.upgrade_subscription()
           |> ErrorMessage.forbidden(%{
             feature_name: feature_name,
             feature_type: feature_type,
             count: count,
             max_count: max_count
           })}
        end

      nil ->
        {:error,
         ServiceError.upgrade_subscription()
         |> ErrorMessage.forbidden(%{feature_name: feature_name, feature_type: feature_type})}
    end
  end

  defp handle_feature_min(%User{} = user, feature_name, feature_type, count) do
    case feature(user, feature_name, feature_type) do
      %{count: min_count} ->
        if count >= min_count do
          :ok
        else
          {:error,
           ServiceError.upgrade_subscription()
           |> ErrorMessage.forbidden(%{
             feature_name: feature_name,
             feature_type: feature_type,
             count: count,
             min_count: min_count
           })}
        end

      nil ->
        {:error,
         ServiceError.upgrade_subscription()
         |> ErrorMessage.forbidden(%{feature_name: feature_name, feature_type: feature_type})}
    end
  end

  defp feature(%User{} = user, feature_name, feature_type) do
    features = Payment.get_active_subscription_features(user.organization_id)

    Enum.find(features, fn feature ->
      feature.name == feature_name && feature.type == feature_type
    end)
  end

  defp handle_claim(%User{} = user, claim_name) do
    if claim?(user, claim_name) do
      :ok
    else
      {:error, ServiceError.upgrade_permission() |> ErrorMessage.forbidden(%{claim: claim_name})}
    end
  end

  defp claim?(%User{} = user, claim_name) do
    claims = Enum.map(user.role.claims, fn claim -> claim.name end)
    Enum.member?(claims, claim_name)
  end
end
