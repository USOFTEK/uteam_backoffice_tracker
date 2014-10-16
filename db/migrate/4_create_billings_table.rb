class CreateBillingsTable < ActiveRecord::Migration
	def change
		create_table(:billings) { |t|
			t.belongs_to(:user)
			t.decimal(:deposit, precision: 15, scale: 6, default: 0.000000)
			t.timestamps
		}
	end	
end
