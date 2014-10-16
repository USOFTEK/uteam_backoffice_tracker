class CreatePhonesTable < ActiveRecord::Migration
	def change
		create_table(:phones) { |t|
			t.belongs_to(:user)
			t.string(:number, limit: 50, null: true, default: nil)
			t.boolean(:is_mobile, default: true)
			t.boolean(:is_main, default: false)
			t.timestamps
		}
	end	
end
