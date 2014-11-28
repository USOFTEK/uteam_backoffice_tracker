require "rubygems"
require "active_support/all"

module APIv1
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
						if params.has_key?(:tv_package_id)
							tv = params[:tv_package_id].zero? ? nil : TvPackage.find(params[:tv_package_id])
							tariff.tv_package = tv
						end
						tariff.save!
					}
				end
			end
		end

	end
end