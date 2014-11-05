require "rubygems"

module Configuration
	DEFAULTS = {
		auth_server: "http://localhost:9005/api/auth/"
	}

	def self.method_missing name, params = {}, &block
		raise "Method missing '#{name}' in '#{self.class.to_s}'" unless DEFAULTS.has_key?(name.to_sym)
		DEFAULTS[name.to_sym]
	end

end
