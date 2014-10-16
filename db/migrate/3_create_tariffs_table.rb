class CreateTariffsTable < ActiveRecord::Migration
	def change
		create_table(:tariffs) { |t|
			t.string(:name)
			t.decimal(:month_fee, precision: 14, scale: 2, default: 0.00)
			t.decimal(:day_fee, precision: 14, scale: 2, default: 0.00)
			t.timestamps
		}
	end	
end
