require "rubygems"
require "active_support/all"

module APIv1
	class Groups < Grape::API

		prefix("api")

    helpers do
      def permitted_params
        params_notoken = params.dup.tap { |h| h.delete(:token) }
        @permitted_params ||= declared(params_notoken, include_missing: false)
      end
    end

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

      desc "Update group data"
      params do
        requires :id, type: String, desc: "Group id"
        optional :tariffs, type: Array, desc: "Array of tariff ids to be associated with group"
        optional :has_no_tariffs, type: Boolean, desc: "If set to true, will empty group's associations with any tariffs"
        optional :can_authorize, type: Boolean

        mutually_exclusive :tariffs, :has_no_tariffs
      end
      put "/:id" do
        within_session(true) do
          group = Group.find(params[:id])
          _ = params.delete :id
          if params[:tariffs]
            old_tariffs = group.tariffs.map(&:id)
            unless old_tariffs.sort == params[:tariffs].sort
              params[:tariffs] = Tariff.find(params[:tariffs]) unless params[:tariffs].empty?
            end
          elsif params[:has_no_tariffs]
            _ = params.delete :has_no_tariffs
            params[:tariffs] = []
          end
          grape_error!(400, group.errors.full_messages.join("; ")) unless group.update(permitted_params)
          { ok: true }.to_json
        end
      end

		end

	end


end
