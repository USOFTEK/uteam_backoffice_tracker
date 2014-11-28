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

      desc "Update tariffs in group"
      params do
        requires :tariff_ids, type: Array, desc: "Array of tariff ids to be associated with group"
        requires :id, type: String, desc: "Group id"
      end
      put "/:id/tariffs" do
        within_session(true) do
          group = Group.find(params[:id])
          old_tariffs = group.tariffs.map(&:id)
          if old_tariffs.sort == params[:tariff_ids].sort
            { ok: true }.to_json
          else
            group.tariffs = params[:tariff_ids].empty? ? [] : Tariff.find(params[:tariff_ids])
            grape_error!(400, group.errors.full_messages.join("; ")) unless group.save
            { ok: true }.to_json
          end
        end
      end

      desc "Update group data"
      params do
        requires :id, type: String, desc: "Group id"
        requires :can_authorize, type: Boolean
      end
      put "/:id" do
        within_session(true) do
          group = Group.find(params[:id])
          grape_error!(400, group.errors.full_messages.join("; ")) unless group.update(permitted_params)
          { ok: true }.to_json
        end
      end

		end

	end


end
