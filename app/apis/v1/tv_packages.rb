require "rubygems"
require "active_support/all"
require "open-uri"
require "ostruct"

module APIv1

	# TV packages
	class TVpackages < Grape::API

		# version("v1", using: :path)

		helpers {
			def retrieve_playlist filename_or_uri
				playlist = Array.new
				file = open(filename_or_uri) { |io| io.read } rescue ""
				unless file.empty?
					lines = file.split("\n")
					lines.shift
					while(!lines.empty?) do
						extinf = lines.shift
						stream = lines.shift
						playlist << { name: File.basename(stream), description: extinf.split(",").last, stream: stream }
					end
				end
				playlist
			end
		}

		prefix("api")


		params do
			requires(:token)
		end
		resource("tv_packages") do

			desc("Load TV packages. Admin only!")
			get("/:token") do
				within_session { |current_user|
					if current_user.nil?
						render_template("/api/v1/tvs/index", TvPackage.all)
					else
						tv_package = current_user.tariff.tv_package
						tv_package = current_user.abonements.with_tv.first if current_user.abonements.with_tv.any?
						grape_error!("TV package not found!", 400) if tv_package.nil?
						playlist = retrieve_playlist(tv_package.source)
						render_template("/api/v1/tvs/show", OpenStruct.new({ object: tv_package, playlist: playlist }))
					end
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