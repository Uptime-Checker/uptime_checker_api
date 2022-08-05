defmodule UptimeChecker.Job.SendNotification do
  alias UptimeChecker.{Customer}

  def work(user_contact_id) do
    user_contact = Customer.get_user_contact_by_id(user_contact_id)

    IO.inspect(user_contact)

    :ok
  end
end
