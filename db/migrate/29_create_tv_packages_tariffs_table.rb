class CreateTvPackagesTariffsTable < ActiveRecord::Migration
	def change
		create_table(:tv_packages_tariffs) { |t|
			t.belongs_to(:tv_package)
			t.belongs_to(:tariff)
			t.timestamps
		}
		add_index(:abonements, :tv_package)
		add_index(:abonements, :tariff)
		add_index(:abonements, [:tariff, :tv_package])
	end
end
