require "rubygems"
require "ostruct"

module Configuration
	OPTIONS = OpenStruct.new({
		auth_server: "http://localhost:9005/api/auth/"
	})

	def self.configure &block
		yield OPTIONS if block_given?
	end

	def self.method_missing name, params = {}, &block
		raise "Method missing '#{name}' in '#{self.class.to_s}'" unless OPTIONS.respond_to?(name.to_sym)
		OPTIONS.send(name.to_sym)
	end

end
