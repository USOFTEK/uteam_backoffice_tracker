# Load app
Dir.glob("#{File.join(File.dirname(__FILE__), "..")}/**/*.rb").each { |f| require f }

# Grape Error
class GrapeError < StandardError
	attr_reader :status

	def initialize status
		@status = status
	end

end

class API < Grape::API

	rescue_from(:all) { |e|
		begin
			status, message = e.status, e.message
		rescue NoMethodError
			status, message = 500, e.message
		end
		Rack::Response.new({
			error: true,
			message: message,
			status: status
		}.to_json, status).finish
	}

	helpers {
		def authenticate! &blk
			if Goliath.env == :test
				blk.call(::User.find(params["user_id"] || 0))
			else
				::Communicator.new(env["config"]["auth.server"]["authorization"]).get_auth(token: params["token"] || "") { |response|
					response = JSON.parse(response) rescue Hash.new
					unauthorized! unless response.has_key?("user_id")
					@user ||= ::User.find(response["user_id"]) rescue nil
					unauthorized! unless @user
					blk.call(@user)
				}
			end
		end

		def render_template(path, object, status = 200,  args = {})
			format = args[:format] || :json
			Rabl::Renderer.new(path, object, { format: format }).render
		end

		def unauthorized!
			grape_error!("Unauthorized!", 401)
		end

		def grape_error! message, status = 401
			raise ::GrapeError.new(status), message
		end

	}

	# # Mount Api v1
	mount(APIv1::Users)
	mount(APIv1::Tariffs)

	resource("/") do
		namespace(:api) do
			namespace(:json_actions) do
				desc("Load all availiable routes", hidden: true)
				get("/") do
					{ actions: API.routes.map { |r| [r.route_method.downcase, r.route_path.gsub(/(\(.*\)|\/api)/, "")] if r.route_path && r.route_path.scan(/(swagger|json_actions)/i).empty? }.compact }.to_json
				end
			end

		end

	end

	add_swagger_documentation(format: :json, hide_format: true, mount_path: "/docs", base_path: lambda { |req| "http://#{req.host}:#{req.port}" } , hide_documentation_path: true)

end