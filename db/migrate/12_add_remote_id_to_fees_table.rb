class AddRemoteIdToFeesTable < ActiveRecord::Migration
  def up
    add_column(:fees, :remote_id, :integer, limit: 11)
  end
  def down
    remove_column(:fees, :remote_id)
  end
end