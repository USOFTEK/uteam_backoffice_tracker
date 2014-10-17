# Load app
Dir.glob("#{File.join(File.dirname(__FILE__), "..")}/**/*.rb").each { |f| require f }

class API < Grape::API

	helpers {
		def authenticate!
			if Goliath.env == :test
				test_authenticate!
			else
				remote_authenticate!(env["config"]["auth.server"]["authorization"], { token: params["token"] || "" })
			end
			@user ||= ::User.find(@USER_ID)
			unauthorized! unless @user
		end

		def test_authenticate!
			@USER_ID = params["user_id"] || 0
		end

		def remote_authenticate! url, params = {}
			request = EM::HttpRequest.new(url).get(query: params)
			unauthorized! unless request.response_header.status == 200 || request.response.has_key?("user_id")
			@USER_ID = request.response["user_id"]
		end

		def current_user
			authenticate! unless @user
			@user
		end

		def render_template(path, object, status = 200,  args = {})
			format = args[:format] || :json
			Rabl::Renderer.new(path, object, { format: format }).render
		end

		def unauthorized!
			error!("Unauthorized!", 401)
		end

	}

	# Mount Api v1
	mount(APIv1::Users)
	mount(APIv1::Tariffs)


	rescue_from(:all) { |e|
		Rack::Response.new({
			error: true,
			message: e.message,
			status: e.status
		}.to_json, e.status).finish
	}

	resource("/") do
		namespace(:api) do
			namespace(:json_actions) do
				desc("Load all availiable routes")
				get("/") do
					{ actions: API.routes.map { |r| [r.route_method.downcase, r.route_path.gsub(/(\(.*\)|\/api)/, "")] if r.route_path && r.route_path.scan(/(swagger|json_actions)/i).empty? }.compact }.to_json
				end
			end

		end

	end

end
