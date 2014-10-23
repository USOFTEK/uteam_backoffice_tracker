class CreateFieldsSettingsTable < ActiveRecord::Migration
	def change
		create_table(:fields_settings) { |t|
			t.string(:object)
			t.string(:selected, null: true, default: nil)
			t.timestamps
		}
		add_index(:fields_settings, :object)
	end	
end
