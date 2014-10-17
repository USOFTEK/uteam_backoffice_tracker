class CreateFieldsSettingsTable < ActiveRecord::Migration
	def change
		create_table(:fields_settings) { |t|
			t.string(:object)
			t.string(:allowed, null: true, default: nil)
			t.string(:disallowed, null: true, default: nil)
			t.timestamps
		}
		add_index(:fields_settings, :object)
	end	
end
