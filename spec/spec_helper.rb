require "rubygems"
require "bundler/setup"
require "goliath/test_helper"
require "em-synchrony/em-http"
require "factory_girl"
require "json"
require "database_cleaner"
require "yaml"
require "em-synchrony/activerecord"
require "faker"
require "paper_trail"
require "rack/test"
require "active_support/all"

# require_relative "factories"

Dir.glob("#{File.join(File.dirname(__FILE__), "..", "app", "models")}/*.rb").each { |m| require m }

Bundler.setup

Goliath.env = :test

db = YAML.load(ERB.new(File.read("#{File.dirname(__FILE__)}/../config/database.yml")).result)[Goliath.env.to_s]
ActiveRecord::Base.establish_connection(db)

RSpec.configure { |config|
  config.include(Goliath::TestHelper, { file_path: /spec\// })
  config.include(FactoryGirl::Syntax::Methods)
  config.include(Rack::Test::Methods)

  config.before(:suite) {
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.start
    DatabaseCleaner.clean
    FactoryGirl.reload
  }

  config.after(:all) {
    DatabaseCleaner.clean
  }

}

require "#{File.dirname(__FILE__)}/../application"
