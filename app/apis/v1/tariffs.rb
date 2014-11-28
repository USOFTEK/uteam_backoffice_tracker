require "rubygems"
require "active_support/all"

module APIv1
	# Tariffs
	class Tariffs < Grape::API

		# version("v1", using: :path)

		helpers {
			def tariff_params
				params.permit(:tv_package_id)
			end
		}

		prefix("api")

		resource("tariffs") do

			desc("Load all tariffs")
			params do
				requires(:token)
			end
			get("/:token") do
				within_session { |current_user|
					render_template("/api/v1/tariffs/index", current_user.nil? ? Tariff.all : current_user.group.tariffs)
				}
			end

			params do
				requires(:id, type: Integer, desc: "Tariff id.")
			end
			route_param(:id) do
				desc("Update tariff.")
				params do
					optional(:tv_package_id, type: Integer, desc: "TV package id.")
				end
				put("/:token") do
					within_session(true) {
						tariff = Tariff.find(params[:id])
						tariff.assign_attributes(tariff_params)
						tariff.save!
					}
				end
			end
		end

	end
end