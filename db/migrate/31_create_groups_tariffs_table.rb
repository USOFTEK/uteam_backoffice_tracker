class CreateGroupsTariffsTable < ActiveRecord::Migration
  def change
    create_table :groups_tariffs do |t|
      t.belongs_to :group
      t.belongs_to :tariff
      t.timestamps
    end
	end	
end
