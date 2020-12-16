# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
require 'selenium-webdriver'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)
# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if Rails.env.production?
Dir[Rails.root.join('spec', 'support', '*.rb')].each { |f| require f }
require 'rspec/rails'

Capybara.register_driver :remote_chrome do |app|
    
  # 要修正 windows wsl2 から vncを用いて グラフィカルにテストする方法
  # 要修正 csvのダウンロードがテストでは機能しない点。おそらくchromedriverの設定
  url = "http://chrome:4444/wd/hub"
  caps = ::Selenium::WebDriver::Remote::Capabilities.chrome(
    "goog:chromeOptions" => {
      "args" => [
        "no-sandbox",
        "headless",
        "disable-gpu",
        "--disable-dev-shm-usage",
        "window-size=1920,1080"
      ],
      "prefs": {
        "download": { 
          "default_directory": DownloadHelper::PATH.to_s
         }
      }
    }
  )
  Capybara::Selenium::Driver.new(app, browser: :remote, url: url, desired_capabilities: caps)


  chrome_options = Selenium::WebDriver::Chrome::Options.new
  chrome_options.headless!
  %w(
    no-sandbox
    disable-gpu
    window-size=1440,900
    disable-desktop-notifications
    disable-extensions
    blink-settings=imagesEnabled=false
    lang=ja
  ).each { |option| chrome_options.add_argument(option) }
  # ダウンロードディレクトリを設定
  chrome_options.add_preference(:download, default_directory: "/tmp/download")
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(chrome_options.as_json)
 Capybara::Selenium::Driver.new(
      app,
      url: url,
      options: chrome_options,
      browser: :remote,
      desired_capabilities: capabilities,
  )
end

Capybara.server_host = '0.0.0.0'
Capybara.javascript_driver = :remote_chrome


# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
# Dir[Rails.root.join('spec', 'support', '**', '*.rb')].sort.each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end
RSpec.configure do |config|

  # download_helper.rb の設定
  config.include DownloadHelper, type: :system, js: true
  config.before(:suite) { Dir.mkdir(DownloadHelper::PATH) unless Dir.exist?(DownloadHelper::PATH) }
  config.after(:example, type: :system, js: true) { clear_downloads }


  config.before(:each, type: :system) do
    driven_by :rack_test
  end

  config.before(:each, type: :system, js: true) do
    driven_by :remote_chrome
    Capybara.server_host = IPSocket.getaddress(Socket.gethostname)
    Capybara.server_port = 3001
    Capybara.app_host = "http://#{Capybara.server_host}:#{Capybara.server_port}"
#    page.driver.browser.download_path = DownloadHelper::PATH

    #if ENV["SELENIUM_DRIVER_URL"].present?
    #  driven_by :selenium, using: :chrome, options: {
    #    browser: :remote,
    #    url: ENV.fetch("SELENIUM_DRIVER_URL"),
    #    desired_capabilities: :chrome
    #    }
    #  else
    #    driven_by :selenium_chrome_headless
    #end
  end

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # You can uncomment this line to turn off ActiveRecord support entirely.
  # config.use_active_record = false

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, type: :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")
  config.include FactoryBot::Syntax::Methods
  config.include SystemHelper, type: :system
end
