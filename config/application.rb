require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
require "sprockets/railtie"
require "omniauth"
require "elasticsearch/model"
require "elasticsearch/rails"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)
Elasticsearch::Model.client = Elasticsearch::Client.new host: ENV['SEARCHBOX_URL']


module ModernBlog
  class Application < Rails::Application
    config.secret_key_base = ENV["SECRET_KEY_BASE"]
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1
    config.session_store :cookie_store, key: '_interslice_session'
    config.middleware.use ActionDispatch::Cookies # Required for all session management
    config.middleware.use ActionDispatch::Session::CookieStore, config.session_options
    # Don't generate system test files.
    config.generators.system_tests = nil
  end
end
