# coding: utf-8
require File.expand_path('../boot', __FILE__)
APP_VERSION = '0.6'

require 'rails/all'

if defined?(Bundler)
  Bundler.require *Rails.groups(:assets => %w(production development test))
end


module RubyChina
  class Application < Rails::Application
    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(#{config.root}/uploaders)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer
    config.time_zone = 'Taipei'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = "zh-TW"

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password,:password_confirm]

    config.assets.enabled = true
    config.assets.version = '1.0'

    config.generators do |g|
      g.orm :active_record
      g.test_framework :rspec
      g.fixture_replacement :factory_girl, :dir => "spec/factories"
    end
  end
end

I18n.locale = 'zh-TW'

require 'yaml'
YAML::ENGINE.yamler= 'syck'

WillPaginate::ViewHelpers.pagination_options[:renderer] = 'BootstrapHelper::PaginateRenderer'

