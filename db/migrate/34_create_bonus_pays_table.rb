class CreateBonusPaysTable < ActiveRecord::Migration
	def change
		create_table(:bonus_pays) { |t|
			t.belongs_to(:user)
			t.date(:day)
			t.float(:amount, default: 0.0)
			t.boolean(:paid, default: false)
		}
		add_index(:teams, [:user_id, :friend_id])
	end	
end
