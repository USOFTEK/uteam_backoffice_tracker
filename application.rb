require "rubygems"
require "bundler/setup"
require "goliath"
require "em-synchrony/activerecord"
require "em-http-request"
require "grape"
require "erb"
require "grape-swagger"
require "active_support/all"

# Load app
require "#{File.dirname(__FILE__)}/app/apis/api.rb"

# Load libs
Dir.glob("#{File.dirname(__FILE__)}/lib/**/*.rb").each { |rb| require rb }

# Application
class Application < Goliath::API
	use Goliath::Rack::Params
	use Goliath::Rack::Formatters::JSON
	use Goliath::Rack::Render

	def response env
		::API.call(env)
	end

end