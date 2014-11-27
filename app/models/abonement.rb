require "active_record"

class Abonement < ActiveRecord::Base
	self.primary_key = :id

	validate(:name, presence: true, uniqueness: true, length: { maximum: 20 })

end
