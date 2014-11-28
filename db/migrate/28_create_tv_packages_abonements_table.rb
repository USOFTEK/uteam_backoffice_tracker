class CreateTvPackagesAbonementsTable < ActiveRecord::Migration
	def change
		create_table(:tv_packages_abonements) { |t|
			t.belongs_to(:tv_package)
			t.belongs_to(:abonement)
			t.timestamps
		}
		add_index(:tv_packages_abonements, :abonement_id)
	end
end
