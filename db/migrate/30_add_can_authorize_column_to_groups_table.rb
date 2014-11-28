class AddCanAuthorizeColumnToGroupsTable < ActiveRecord::Migration
	def up
		add_column(:groups, :can_authorize, :boolean, default: true)
	end
	def down
		remove_column(:groups, :can_authorize)
	end
end
