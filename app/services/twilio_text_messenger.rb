# frozen_string_literal: true

class TwilioTextMessenger
  attr_reader :to, :message

  def initialize(to, message)
    @to = to
    @message = message
  end

  def call
    client = Twilio::REST::Client.new
    client.messages.create({
      from: Rails.application.credentials.dig(:twilio, :sender_id),
      to: to,
      body: message
    })
  end
end
