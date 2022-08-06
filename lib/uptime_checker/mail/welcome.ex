defmodule UptimeChecker.Mail.Welcome do
  import Bamboo.Email

  def compose do
    new_email(
      to: "mr.k779@gmail.com",
      from: "no-reply@uptimecheckr.com",
      subject: "Welcome to the app.",
      html_body: "<strong>Thanks for joining!</strong>",
      text_body: "Thanks for joining!"
    )
  end
end
