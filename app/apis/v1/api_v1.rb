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

				namespace(:update) do

					namespace(:email) do
						desc("Update user email")
						params do
							requires(:token)
							requires(:email)
						end
						put("/:token") do
							within_session { |current_user|
								current_user.email = params["email"]
								error!("Invalid email!", 400) unless current_user.valid?
								current_user.save!
							}
						end

					end

				end

				namespace(:delete) do
					desc("Delete user password by token")
					params do
						requires(:token)
					end
					delete("/password/:token") do
						within_session { |current_user|
							current_user.password_hash = ""
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
						optional(:date_from, type: Integer)
						optional(:date_to, type: Integer)
					end
					get("/:token") do
						within_session { |current_user|
							params[:date_from] ||= 0
							params[:date_to] ||= Time.now.midnight + 1.day
							from = Time.at(params[:date_from])
							to = Time.at(params[:date_to])
							render_template("/api/v1/users/statistics/networks", current_user.network_activities.where(per: from..to).order(per: :asc))
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
				render_template("/api/v1/tariffs/index", Tariff.all)
			end

		end

	end

end
