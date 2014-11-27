require "active_record"

class Abonement < ActiveRecord::Base
	self.primary_key = :id

	has_many(:tv_packages_abonements)

	has_many(:tv_packages, through: :tv_packages_abonements)

	validate(:name, presence: true, uniqueness: true, length: { maximum: 20 })

end
