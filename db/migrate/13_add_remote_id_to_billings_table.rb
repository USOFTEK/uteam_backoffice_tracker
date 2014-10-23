class AddRemoteIdToBillingsTable < ActiveRecord::Migration
  def up
    add_column(:billings, :remote_id, :integer, limit: 11)
  end
  def down
    remove_column(:billings, :remote_id)
  end
end