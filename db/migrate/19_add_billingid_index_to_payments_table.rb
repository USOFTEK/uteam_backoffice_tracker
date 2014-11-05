class AddBillingidIndexToPaymentsTable < ActiveRecord::Migration
  def up
    add_index(:payments, :billing_id)
  end
  def down
    remove_index(:payments, :billing_id)
  end
end
