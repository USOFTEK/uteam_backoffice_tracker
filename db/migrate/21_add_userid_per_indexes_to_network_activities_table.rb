class AddUseridPerIndexesToNetworkActivitiesTable < ActiveRecord::Migration
  def up
    add_index(:network_activities, :user_id)
    add_index(:network_activities, :per)
  end
  def down
    remove_index(:network_activities, :user_id)
    remove_index(:network_activities, :per)
  end
end
