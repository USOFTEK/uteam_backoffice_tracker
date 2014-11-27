class CreateGroupsTable < ActiveRecord::Migration
	def change
		create_table(:groups, id: false) { |t|
			t.integer(:id, limit: 4)
			t.string(:name, limit: 30, default: "")
			t.string(:description, limit: 200, default: "")
			t.timestamps
		}
		add_index(:groups, :id)
		add_index(:groups, :name, unique: true)
	end	
end
