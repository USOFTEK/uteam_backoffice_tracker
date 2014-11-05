class AddNameIndexToTariffsTable < ActiveRecord::Migration
  def up
    add_index(:tariffs, :name)
  end
  def down
    remove_index(:tariffs, :name)
  end
end
