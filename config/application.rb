require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_mailbox/engine"
require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
# require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ApiKolakolaApp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    config.autoload_paths += %W[
      #{Rails.root}/lib
      #{Rails.root}/config/routes
      #{Rails.root}/app/services
    ]

    config.time_zone = 'Madrid'
    config.active_record.default_timezone = :local

    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]

    config.i18n.available_locales = %i[es]
    config.i18n.default_locale = :es

    config.application = config_for(:application)
    
    config.api_only = true

    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = Rails.application.credentials.smtp_settings

    config.middleware.use ActionDispatch::Cookies
  end
end
