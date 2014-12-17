class CreateTeamsTable < ActiveRecord::Migration
	def change
		create_table(:teams) { |t|
			t.belongs_to(:user)
			t.belongs_to(:friend)
		}
	end	
end
