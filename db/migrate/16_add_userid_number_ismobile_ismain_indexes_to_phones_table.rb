class AddUseridNumberIsmobileIsmainIndexesToPhonesTable < ActiveRecord::Migration
  def up
    add_index(:phones, :number)
    add_index(:phones, :is_mobile)
    add_index(:phones, :is_main)
    add_index(:phones, :user_id)
  end
  def down
    remove_index(:phones, :number)
    remove_index(:phones, :is_mobile)
    remove_index(:phones, :is_main)
    remove_index(:phones, :user_id)
  end
end
