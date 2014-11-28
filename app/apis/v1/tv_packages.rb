require "rubygems"
require "active_support/all"

module APIv1

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
					optional(:description, type: String, desc: "TV package description.")
					optional(:abonement, type: Integer, desc: "Abonement id.")
				end
				put("/:token") do
					within_session(true) {
						package = TvPackage.find(params[:id])
						package.name = params[:name]
						package.source = params[:source]
						package.description = params[:description] if params.has_key?(:description)
						if params.has_key?(:abonement)
							if params[:abonement].empty?
								package.tv_packages_abonements.delete
							else
								package.tv_packages_abonements.first_or_create.update_attributes(abonement_id: params[:abonement])
							end
						end
						package.save!
					}
				end
			end

		end

	end

end