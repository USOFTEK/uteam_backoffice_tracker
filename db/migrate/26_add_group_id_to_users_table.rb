class AddGroupIdToUsersTable < ActiveRecord::Migration
  def up
    add_column(:users, :group_id, :integer, limit: 4)
  end
  def down
    remove_column(:users, :group_id)
  end
end