class ApplicationMailer < ActionMailer::Base
  default from: Rails.application.credentials.dig(:smtp_settings, :from)
  layout 'mailer'
end
