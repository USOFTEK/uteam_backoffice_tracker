require "active_record"

class Abonement < ActiveRecord::Base
	self.primary_key = :id

	has_many(:tv_packages_abonements)
	has_many(:tv_packages, through: :tv_packages_abonements)

	has_many :abonement_users
	has_many(:users, through: :abonement_users)

	validate(:name, presence: true, uniqueness: true, length: { maximum: 20 })

	scope(:with_tv, -> { includes(:tv_packages).where.not(tv_packages: { id: nil }) })

end
