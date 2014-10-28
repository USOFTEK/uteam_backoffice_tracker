class CreateNetworkActivitiesTable < ActiveRecord::Migration
	def change
		create_table(:network_activities) { |t|
			t.belongs_to(:user)
			t.integer(:sent, limit: 8)
			t.integer(:received, limit: 8)
			t.datetime(:per, null: true, default: nil)
			t.timestamps
		}
	end
end
