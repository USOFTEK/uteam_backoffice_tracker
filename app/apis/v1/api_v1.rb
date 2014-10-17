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
			namespace :check do
				post("/:username/:password") do
					user = User.find_by(username: params["username"])
					error!("Invalid username or password", 401) unless user.authenticate(params["password"])
					render_template("/api/v1/users/check", user)
				end

			end

			namespace(:profile) do
				desc("Load user profile")
				params do
					requires(:token)
				end
				get("/:token") do
					render_template("/api/v1/users/show", current_user)
				end

				namespace(:update) do
					desc("Update user email")
					params do
						requires(:token)
						requires(:email)
					end
					put("/email/:token") do
						current_user.email = params["email"]
						error!("Invalid email!", 400) unless current_user.valid?
						current_user.save!
					end

				end

			end

			namespace(:statistics) do
				namespace(:payments) do
					desc("Load user payments statistic")
					params do
						requires(:token)
					end
					get("/:token") do
						from = Time.at(params["date_from"]) rescue Time.new(0)
						to = Time.at(params["date_to"]) rescue Time.now.midnight + 1.day
						render_template("/api/v1/users/statistics/payments", current_user.payments.where(created_at: from..to).order(:created_at))
					end
				end

				namespace(:fees) do
					desc("Load user fees statistic")
					params do
						requires(:token)
					end
					get("/:token") do
						from = Time.at(params["date_from"]) rescue Time.new(0)
						to = Time.at(params["date_to"]) rescue Time.now.midnight + 1.day
						render_template("/api/v1/users/statistics/fees", current_user.fees.where(created_at: from..to).order(:created_at))
					end
				end

				namespace(:networks) do
					desc("Load user network statistic")
					params do
						requires(:token)
					end
					get("/:token") do
						from = Time.at(params["date_from"]) rescue Time.new(0)
						to = Time.at(params["date_to"]) rescue Time.now.midnight + 1.day
						render_template("/api/v1/users/statistics/networks", current_user.network_activities.where(created_at: from..to).order(:created_at))
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
				render_template("/api/v1/tariffs/index", Tariff.all)
			end

		end

	end

end
