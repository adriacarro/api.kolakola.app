# frozen_string_literal: true

class TwilioTextMessenger
  attr_reader :to, :message

  def initialize(to, message)
    @to = to
    @message = message
  end

  def call
    begin
      client = Twilio::REST::Client.new
      client.messages.create({
        from: Rails.application.credentials.dig(:twilio, :sender_id),
        to: to,
        body: message
      })
    rescue Twilio::REST::RestError => e
      puts e.message
    end
  end
end
