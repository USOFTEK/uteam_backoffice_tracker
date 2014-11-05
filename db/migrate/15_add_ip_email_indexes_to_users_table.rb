class AddIpEmailIndexesToUsersTable < ActiveRecord::Migration
  def up
    add_index(:users, :ip)
    add_index(:users, :email)
  end
  def down
    remove_index(:users, :ip)
    remove_index(:users, :email)
  end
end