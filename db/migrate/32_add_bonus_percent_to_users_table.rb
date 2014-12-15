class AddBonusPercentToUsersTable < ActiveRecord::Migration
	def up
		add_column(:users, :bonus_percent, :integer, default: 0)
	end
	def down
		remove_column(:users, :bonus_percent)
	end
end
