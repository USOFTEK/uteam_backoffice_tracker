require "rubygems"
require "active_support/all"

module APIv1
	class Groups < Grape::API

		prefix("api")

		params do
			requires(:token, desc: "Session token.")
		end
		namespace(:groups) do

			desc "Display all groups within admin session."
      params do
        optional :with_tariffs, type: Boolean, default: true
      end
			get ["/", "/:id"] do
				within_session(true) do
          q = params[:id] ? { id: params[:id] } : {}
					(Group.where(q).extend(Presenters::GroupsPresenter).to_hash(with_tariffs: params[:with_tariffs])).to_json
				end
      end

      desc "Delete or insert new tariffs into group"
      params do
        requires :tariff_ids, type: Array, desc: "Array of tariff ids to be associated with group"
        requires :id, type: String, desc: "Group id"
      end
      put "/:id" do
        within_session(true) do
          group = Group.find(params[:id])
          tariffs = group.tariffs
        end
      end

		end

	end


end
