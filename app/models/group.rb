require "active_record"

class Group < ActiveRecord::Base
	self.primary_key = :id

	has_many :users

	has_many(:groups_tariffs)

	has_many(:tariffs, through: :groups_tariffs)

	validates(:name, presence: true, uniqueness: true, length: { maximum: 30 })

	validates(:description, length: { maximum: 200 })

	def authorizable?
		can_authorize
	end

end
