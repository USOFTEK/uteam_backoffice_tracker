require "active_record"

class Abonement < ActiveRecord::Base
	self.primary_key = :id

  has_many :abonement_users
  has_many(:users, through: :abonement_users)

	validate(:name, presence: true, uniqueness: true, length: { maximum: 20 })

end
