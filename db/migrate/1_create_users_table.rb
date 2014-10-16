class CreateUsersTable < ActiveRecord::Migration
	def change
		create_table(:users) { |t|
			t.belongs_to(:tariff)
			t.string(:initials)
			t.string(:address_street)
			t.string(:address_build)
			t.string(:address_flat)
			t.string(:email)
			t.string(:ip)
			t.string(:netmask)
			t.string(:speed)
			t.string(:username, default: "")
			t.string(:password_hash, limit: 256)
			t.date(:registration, null: true, default: nil)
			t.timestamps
		}
		add_index(:users, :username, unique: true)
	end	
end
