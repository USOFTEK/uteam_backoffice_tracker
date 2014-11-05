class AddUseridIndexToBillingsTable < ActiveRecord::Migration
  def up
    add_index(:billings, :user_id)
  end
  def down
    remove_index(:billings, :user_id)
  end
end
