class CreateTvPackagesAbonementsTable < ActiveRecord::Migration
	def change
		create_table(:tv_packages_abonements) { |t|
			t.belongs_to(:tv_package)
			t.belongs_to(:abonement)
			t.timestamps
		}
		add_index(:abonements, :tv_package)
		add_index(:abonements, :abonement)
		add_index(:abonements, [:abonement, :tv_package])
	end
end
