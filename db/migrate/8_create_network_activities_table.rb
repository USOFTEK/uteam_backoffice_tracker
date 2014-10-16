class CreateNetworkActivitiesTable < ActiveRecord::Migration
	def change
		create_table(:network_activities) { |t|
			t.belongs_to(:user)
			t.integer(:sent)
			t.integer(:received)
			t.datetime(:per, null: true, default: nil)
			t.timestamps
		}
	end
end
