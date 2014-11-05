config["auth.server"] = {
  "authorization" => "http://localhost:9005/api/auth/",
  "authentication" => lambda { |token, &block|
    auth = Communicator.new(env["config"]["auth.server"]["authorization"])
    auth.get(token: params[:token]) do |response|
      response = JSON.parse(response) rescue Hash.new
      grape_error!("Authentication failue!", 401) if response.has_key?("error")
      if eval("#{response["is_admin"]}")
        block.call if block_given?
      else
        user = ::User.find(response["user_id"].to_i)
        unauthorized! unless user
        block.call(user) if block_given?
      end
    end
  }
}

db = YAML.load(ERB.new(File.read("#{File.dirname(__FILE__)}/database.yml")).result)[Goliath.env.to_s]
ActiveRecord::Base.establish_connection(db)

require "rabl"
Rabl.configure { |config|
  # Commented as these are defaults
  # config.cache_all_output = false
  # config.cache_sources = Rails.env != 'development' # Defaults to false
  # config.cache_engine = Rabl::CacheEngine.new # Defaults to Rails cache
  # config.perform_caching = false
  # config.escape_all_output = false
  # config.json_engine = nil # Class with #dump class method (defaults JSON)
  # config.msgpack_engine = nil # Defaults to ::MessagePack
  # config.bson_engine = nil # Defaults to ::BSON
  # config.plist_engine = nil # Defaults to ::Plist::Emit
  config.include_json_root = false
  # config.include_msgpack_root = true
  # config.include_bson_root = true
  # config.include_plist_root = true
  # config.include_xml_root  = false
  config.include_child_root = false
  # config.enable_json_callbacks = false
  # config.xml_options = { :dasherize  => true, :skip_types => false }
  config.view_paths = ["#{File.expand_path(File.join(File.dirname(__FILE__), "..",  "app", "views"))}"]
  # config.raise_on_missing_attribute = true # Defaults to false
  # config.replace_nil_values_with_empty_strings = true # Defaults to false
  # config.replace_empty_string_values_with_nil_values = true # Defaults to false
  # config.exclude_nil_values = true # Defaults to false
  # config.exclude_empty_values_in_collections = true # Defaults to false
}
