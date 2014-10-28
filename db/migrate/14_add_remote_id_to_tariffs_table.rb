class AddRemoteIdToTariffsTable < ActiveRecord::Migration
  def up
    add_column(:tariffs, :remote_id, :integer, limit: 11)
  end
  def down
    remove_column(:tariffs, :remote_id)
  end
end