require "active_record"

class Group < ActiveRecord::Base
	self.primary_key = :id

  has_many :users

	validate(:name, presence: true, uniqueness: true, length: { maximum: 30 })

	validate(:description, length: { maximum: 200 })

end
