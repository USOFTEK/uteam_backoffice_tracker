class CreateAbonementUsersTable < ActiveRecord::Migration
  def change
    create_table :abonement_users do |t|
      t.belongs_to :user
      t.belongs_to :abonement
      t.timestamps
    end
	end	
end
