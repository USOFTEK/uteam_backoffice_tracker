class AddTvPackageIdToTariffsTable < ActiveRecord::Migration
  def up
    add_column(:tariffs, :tv_package_id, :integer, limit: 11, default: 0)
  end
  def down
    remove_column(:tariffs, :tv_package_id)
  end
end