require "rubygems"
require "active_support/all"

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

	$auth_server_api = ::Communicator.new(Configuration.auth_server)

	rescue_from(ActiveRecord::RecordInvalid) { |e|
		Rack::Response.new({
			error: true,
			message: e.record.errors.full_messages.join("; "),
			status: 400
		}.to_json, 400).finish
	}

	rescue_from(ActiveRecord::RecordNotFound) { |e|
		Rack::Response.new({
			error: true,
			message: "Authentication failue!",
			status: 401
		}.to_json, 401).finish
	}

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
		# Session helper
		def within_session rule = nil, &block
			user = nil
			if Goliath.env == :test
				params[:is_admin] ||= false
				grape_error!("Permission denied!", 401) if !rule.nil? && rule != eval(params[:is_admin].to_s)
				unless eval(params[:is_admin].to_s)
					user = ::User.find(params[:user_id] || nil)
					unauthorized! unless user
				end
				block.call(user) if block_given?
			else
				$auth_server_api.get_auth(token: params[:token]) do |response|
					response = JSON.parse(response) rescue Hash.new
					grape_error!("Authentication failue!", 401) if response.has_key?("error")
					grape_error!("Permission denied!", 401) if !rule.nil? && rule != eval(params["is_admin"].to_s)
					unless eval(response["is_admin"].to_s)
						user = ::User.find(response["user_id"].to_i)
						unauthorized! unless user
					end
					block.call(user) if block_given?
				end
			end
		end

		def unauthorized!
			grape_error!("Unauthorized!", 401)
		end

		# Date range of statistics helper
		def make_date_range from, to, keys = { sent: 0, received: 0 }
			range = Hash.new
			return range if Time.at(to) < Time.at(from)
			from = Time.at(from).to_date
			to = Time.at(to).to_date
			(to - from).to_i.times { |i|
				index = from + i.day
				range[index.to_s] = OpenStruct.new(keys.merge(date: index.to_time.to_i))
			}
			range
		end

		# Rabl render helper
		def render_template path, object, status = 200,  args = {}
			format = args[:format] || :json
			Rabl::Renderer.new(path, object, { format: format }).render
		end

		# Grape error helper
		def grape_error! message, status = 401
			raise ::GrapeError.new(status), message
		end

		# Make month weeks ranges
		def month_weeks_ranges year, month
			date = Date.new(year, month)
			sundays = (date.beginning_of_month..date.end_of_month).select(&:sunday?)
			sundays.push([date.beginning_of_month, date.end_of_month])
			sundays.flatten.uniq.sort.to_weeks_ranges
		end

		# Make year months ranges
		def year_month_ranges year
			from = Date.new(year, Time.now.month) - 1.year
			to = Date.new(year, Time.now.month)
			(from..to).group_by(&:month).map { |n,v| v.first.beginning_of_month.to_s..v.first.end_of_month.to_s }
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