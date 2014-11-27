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
					within_session(false) { |current_user|
						render_template("/api/v1/users/show", current_user)
					}
				end

				desc("Update user profile by allowed fields")
				params do
					requires(:token)
					group(:mobile_phone_attributes, type: Hash) do
						requires(:number, type: String, desc: "Mobile phone number.")
					end
					optional(:chat_notification, type: Boolean, desc: "Allow/disallow chat notification.")
				end
				put("/:token") do
					within_session(false) { |current_user|
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
						within_session(true) {
							fields = params[:fields] || Hash.new
							fields = eval(params[:fields]) unless fields.is_a?(Hash)
							object = FieldsSetting.where(object: User.to_s.downcase).first_or_create
							object.disallowed_fields = fields.values.select { |k| User.public_fields.include?(k.to_sym) }.compact
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
						within_session(false) { |current_user|
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
						within_session(false) { |current_user|
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
						optional(:from, type: Integer, desc: "Display statistics per date from this date. Default: from beginning.")
						optional(:to, type: Integer, desc: "Display statistics per date till this date. Default: current day midnight.")
					end
					get("/:token") do
						within_session(false) { |current_user|
							to_object = Array.new
							
							if params.has_key?(:from)
								params[:to] ||= Time.now.midnight.to_i
								params[:from] ||= 0

								to_object = current_user.network_activities.where(per: Time.at(params[:from]).to_s..Time.at(params[:to]).to_s).group(:per).order(per: :asc)

							else

								params[:year] ||= Time.now.to_date.year

								if params[:year] >= current_user.registration.year

									ranges = params.has_key?(:month) ? month_weeks_ranges(params[:year], params[:month]) : year_month_ranges(params[:year])

									ranges.each { |range|
										records = current_user.network_activities.where(per: range)
										to_object.push(OpenStruct.new({ sent: records.sum(:sent), received: records.sum(:received), from: Date.parse(range.first).to_time.to_i, to: Date.parse(range.last).to_time.to_i }))
									}

								end
							end
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
						within_session(false) { |current_user|
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
						within_session(false) { |current_user|
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

	# TV packages
	class TVpackages < Grape::API

		# version("v1", using: :path)

		prefix("api")


		params do
			requires(:token)
		end
		resource("tv_packages") do

			desc("Load TV packages. Admin only!")
			get("/:token") do
				within_session(true) {
					render_template("/api/v1/tvs/index", TvPackage.all)
				}
			end


			desc("Create new TV package. Admin only!")
			params do
				requires(:name, type: String, desc: "TV package name.")
				requires(:source, type: String, desc: "Package play list source url.")
				optional(:description, type: String, desc: "TV package description")
			end
			post("/:token") do
				within_session(true) {
					params[:description] ||= ""
					package = TvPackage.new(name: params[:name], source: params[:source], description: params[:description])
					package.save!
				}
			end

			desc("Update TV package. Admin only!")
			params do
				requires(:id, type: Integer, desc: "TV package ID.")
			end
			route_param(:id) do
				desc("Delete package. Admin only!")
				delete("/:token") do
					within_session(true) {
						TvPackage.find(params[:id]).destroy
					}
				end

				desc("Update TV package. Admin only!")
				params do
					requires(:name, type: String, desc: "TV package name.")
					requires(:source, type: String, desc: "Package play list source url.")
					optional(:description, type: String, desc: "TV package description")
				end
				put("/:token") do
					within_session(true) {
						package = TvPackage.find(params[:id])
						package.name = params[:name]
						package.source = params[:source]
						package.description = params[:description] if params.has_key?(:description)
						package.save!
					}
				end
			end

		end

	end

	# Groups
	class Groups < Grape::API

		# version("v1", using: :path)

		prefix("api")

		params do
			requires(:token, desc: "Session token.")
		end
		namespace(:groups) do

			desc("Display all groups within admin session.")
			get("/:token") do
				within_session(true) {
					render_template("/api/v1/groups/index", Group.all)
				}
			end

		end

	end

end
