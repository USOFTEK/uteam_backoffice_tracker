class CreateTvPackagesTable < ActiveRecord::Migration
	def change
		create_table(:tv_packages) { |t|
			t.string(:name)
			t.text(:source)
			t.string(:description)
			t.timestamps
		}
		add_index(:tv_packages, :name, unique: true)
	end	
end
