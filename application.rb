require "rubygems"
require "bundler/setup"
require "goliath"
require "em-synchrony"
require "em-synchrony/activerecord"
require "em-http-request"
require "grape"
require "erb"
require "grape-swagger"
require "active_support/all"
require "json"
require "net/http"
require "ostruct"

# Load libs
Dir.glob("#{File.dirname(__FILE__)}/lib/**/*.rb").each { |rb| require rb }

# Load configs
require "#{File.dirname(__FILE__)}/config/configuration.rb"

# Load app
require "#{File.dirname(__FILE__)}/app/apis/api.rb"

# Application
class Application < Goliath::API
	
	def response env
		::API.call(env)
	end

end
