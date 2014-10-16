class CreateFeesTable < ActiveRecord::Migration
	def change
		create_table(:fees) { |t|
			t.belongs_to(:billing)
			t.decimal(:amount, precision: 12, scale: 2, default: 0.00)
			t.decimal(:deposit, precision: 15, scale: 6, default: 0.000000)
			t.string(:description, default: "")
			t.string(:ip, default: "")
			t.timestamps
		}
	end
end
