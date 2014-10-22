class AddRemoteIdToPaymentsTable < ActiveRecord::Migration
  def up
    add_column(:payments, :remote_id, :integer, limit: 11)
  end
  def down
    remove_column(:payments, :remote_id)
  end
end