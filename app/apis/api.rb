# Require API versions
Dir.glob("#{File.dirname(__FILE__)}/**/*.rb").each { |f| require f }

class API < Grape::API

	helpers {
		def authenticate!
			@USER_ID = if Goliath.env == :test
				params["user_id"] || 0
			else
				request = EM::HttpRequest.new(env["config"]["auth.server"]["authorization"]).get(query: { token: params["token"] || ""})
				error!({ error: e.message }, 401) unless request.response_header.status == 200 || request.response.has_key?("USER_DATA")
				request.response["user_id"]
			end	
		end

		def current_user
			authenticate! unless @user
			@user ||= User.find(@USER_ID)
		end

		def render_template(path, object, status = 200,  args = {})
			format = args[:format] || :json
			Rabl::Renderer.new(path, object, { format: format }).render
		end

	}

	# Mount Api v1
	mount(APIv1::Users)
	mount(APIv1::Tariffs)


	rescue_from(:all) { |e|
		Rack::Response.new({
			error_code: 500,
			error_message: e.message
		}.to_json, 500).finish
	}

	resource("/") do
		namespace(:api) do
			namespace(:json_actions) do
				desc("Load all availiable routes")
				get("/") do
					API.routes.map { |r| [r.route_method.downcase, r.route_path.gsub(/(\(.*\)|\/api)/, "")] if r.route_path && r.route_path.scan(/(swagger|json_actions)/i).empty? }.compact
				end
			end

		end

	end

	# Mount swagger
	add_swagger_documentation(hide_format: true, models: [APIv1::Users, APIv1::Tariffs])

end
