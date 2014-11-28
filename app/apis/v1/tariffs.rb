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
					optional(:package, allow_blank: true, type: Integer, desc: "TV package id.")
				end
				put("/:token") do
					tariff = Tariff.find(params[:id])
					if params.has_key?(:package)
						if params[:package].empty?
							tariff.tv_packages_tariffs.destroy
						else
							tariff.tv_packages_tariffs.first_or_create.update_attributes(tv_package_id: params[:package])
						end
					end
				end
			end
		end

	end
end