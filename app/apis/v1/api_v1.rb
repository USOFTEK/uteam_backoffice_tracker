require "rubygems"
require "active_support/all"

module APIv1
	# Users
	class Users < Grape::API

		# version("v1", using: :path)

		prefix("api")

		resource("users") do

			desc("Returns userdata by username and password")
			params do
				requires(:username)
				requires(:password)
			end
			namespace(:check) do
				post("/") do
					user = User.find_by(username: params["username"])
					unauthorized! if user.nil? || !user.authenticate(params["password"])
					render_template("/api/v1/users/check", user)
				end

			end

			namespace(:profile) do
				desc("Load user profile")
				params do
					requires(:token)
				end
				get("/:token") do
					within_session { |current_user|
						render_template("/api/v1/users/show", current_user)
					}
				end

				desc("Update user profile by allowed fields")
				params do
					requires(:token)
				end
				put("/:token") do
					within_session { |current_user|
						fields = FieldsSetting.where(object: current_user.class.to_s.downcase).first_or_create
						attributes = params.reject { |k,v| !User.public_fields.include?(k.to_sym) || fields.disallowed_fields.include?(k) }.to_hash
						grape_error!("Bad request!", 400) if attributes.empty?
						current_user.assign_attributes(attributes)
						current_user.save!
					}
				end

				namespace(:fields) do
					get("/:token") do
						within_session {
							fields = FieldsSetting.where(object: User.to_s.downcase).first_or_create
							render_template("/api/v1/users/profile/fields", OpenStruct.new({available: User.available_fields(fields.disallowed_fields)}))
						}
					end
					
					desc("Update editable fields")
					params do
						requires(:token)
						optional(:fields)
					end
					put("/:token") do
						within_session {
							fields = params[:fields] || Hash.new
							fields = eval(params[:fields]) unless fields.is_a?(Hash)
							object = FieldsSetting.where(object: User.to_s.downcase).first_or_create
							object.disallowed_fields = fields.values.select { |k| User.public_fields.include?(k.to_sym) }.compact
							object.save!
							object.reload
							render_template("/api/v1/users/profile/fields", OpenStruct.new({available: User.available_fields(object.disallowed_fields)}))
						}
					end

				end

				namespace(:email) do
					desc("Update user email")
					params do
						requires(:token)
						requires(:email)
					end
					put("/:token") do
						within_session { |current_user|
							current_user.email = params["email"]
							current_user.save!
						}
					end

				end

				namespace(:password) do
					desc("Delete user password by token")
					params do
						requires(:token)
					end
					delete("/:token") do
						within_session { |current_user|
							current_user.password = ""
							current_user.save!
						}
					end

				end

			end

			namespace(:statistics) do

				namespace(:networks) do
					desc("Load user network statistic")
					params do
						requires(:token)
						optional(:year, type: Integer, desc: "Year to display graph. Default: current year. Value exmpl: 2014.")
						optional(:month, type: Integer, desc: "Month of the year. Default: none, display by year months ranges. If month present - display graph in order of month weeks.")
					end
					get("/:token") do
						within_session { |current_user|
							to_object = Array.new

							params[:year] ||= Time.now.to_date.year

							params[:year] = current_user.registration.year if params[:year] > current_user.registration.year

							ranges = params.has_key?(:month) ? month_weeks_ranges(params[:year], params[:month]) : year_month_ranges(params[:year])

							ranges.each { |range|
								records = current_user.network_activities.where(per: range)
								to_object << OpenStruct.new({ sent: records.sum(:sent), received: records.sum(:received), date: Date.parse(range.first).to_time.to_i }) if records.any?
							}
							render_template("/api/v1/users/statistics/networks", to_object)
							# render_template("/api/v1/users/statistics/networks", current_user.network_activities.where(per: from..to).order(per: :asc).group(:per))
						}
					end

				end

			end

			namespace(:billing) do

				namespace(:payments) do
					desc("Load user payments statistic")
					params do
						requires(:token)
						optional(:date_from, type: Integer)
						optional(:date_to, type: Integer)
					end
					get("/:token") do
						within_session { |current_user|
							params[:date_from] ||= 0
							params[:date_to] ||= Time.now.midnight + 1.day
							from = Time.at(params[:date_from])
							to = Time.at(params[:date_to])
							render_template("/api/v1/users/statistics/payments", current_user.payments.where(created_at: from..to).order(created_at: :asc))
						}
					end
				end

				namespace(:fees) do
					desc("Load user fees statistic")
					params do
						requires(:token)
						optional(:date_from, type: Integer)
						optional(:date_to, type: Integer)
					end
					get("/:token") do
						within_session { |current_user|
							params[:date_from] ||= 0
							params[:date_to] ||= Time.now.midnight + 1.day
							from = Time.at(params[:date_from])
							to = Time.at(params[:date_to])
							render_template("/api/v1/users/statistics/fees", current_user.fees.where(created_at: from..to).order(created_at: :asc))
						}
					end
				end
				
			end

		end
		
	end

	# Tariffs
	class Tariffs < Grape::API

		# version("v1", using: :path)

		prefix("api")

		resource("tariffs") do

			desc("Load all tariffs")
			params do
				requires(:token)
			end
			get("/:token") do
				within_session {
					render_template("/api/v1/tariffs/index", Tariff.all)
				}
			end

		end

	end

end
