class AddTvPackageIdToTariffsTable < ActiveRecord::Migration
  def up
    add_column(:tariffs, :tv_package_id, :integer, limit: 11)
  end
  def down
    remove_column(:tariffs, :tv_package_id)
  end
end