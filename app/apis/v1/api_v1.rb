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
						begin
							fields = FieldsSetting.where(object: current_user.class.to_s.downcase).first_or_create
							attributes = params.reject { |k,v| !User.public_fields.include?(k.to_sym) || fields.disallowed_fields.include?(k) }.to_hash
							grape_error!("Invalid fields or bad request!", 400) if attributes.empty?
							current_user.assign_attributes(attributes)
							current_user.save!
						rescue ActiveRecord::RecordInvalid => invalid
							grape_error!(invalid.record.errors.full_messages.join("; "), 400)
						end
					}
				end

				namespace(:fields) do
					desc("Display allowed fields to update in user")
					params do
						requires(:token)
					end
					get("/:token") do
						within_session { |current_user|
							render_template("/api/v1/users/profile/fields", FieldsSetting.where(object: current_user.class.to_s.downcase).first_or_create)
						}
					end
					
					desc("Update editable fields")
					params do
						requires(:token)
						requires(:fields, type: Array)
					end
					put("/:token") do
						within_session {
							object = FieldsSetting.where(object: User.to_s.downcase).first_or_create
							object.disallowed_fields = params["fields"].map { |k| k.to_sym if User.public_fields.include?(k.to_sym) }.compact
							object.save!
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
							error!("Invalid email!", 400) unless current_user.valid?
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
						optional(:date_from, type: Integer)
						optional(:date_to, type: Integer)
					end
					get("/:token") do
						within_session { |current_user|
							params[:date_from] ||= Time.now.midnight - 1.month
							params[:date_to] ||= params[:date_from] + 1.month
							from = Time.at(params[:date_from])
							to = Time.at(params[:date_to])
							range = make_date_range(from, to)
							current_user.network_activities.where(per: from..to).order(per: :asc).group(:per).each { |record|
								range[record.per_date] = OpenStruct.new({ sent: record.sent, received: record.received, date: record.at })
							}
							render_template("/api/v1/users/statistics/networks", range.values)
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
				render_template("/api/v1/tariffs/index", Tariff.all)
			end

		end

	end

end
