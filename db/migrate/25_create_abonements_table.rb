class CreateAbonementsTable < ActiveRecord::Migration
	def change
		create_table(:abonements, id: false) { |t|
			t.integer(:id, limit: 6)
			t.string(:name, limit: 20, default: "")
			t.integer(:period, limit: 2, default: 0)
			t.decimal(:cost, precision: 14, scale: 2, default: 0.00)
			t.boolean(:payment_type, default: false)
			t.timestamps
		}
		add_index(:abonements, :id)
		add_index(:abonements, :name, unique: true)
	end
end
