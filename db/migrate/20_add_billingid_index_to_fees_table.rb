class AddBillingidIndexToFeesTable < ActiveRecord::Migration
  def up
    add_index(:fees, :billing_id)
  end
  def down
    remove_index(:fees, :billing_id)
  end
end
