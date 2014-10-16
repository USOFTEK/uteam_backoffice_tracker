require "active_record"

class NetworkActivity < ActiveRecord::Base
	
	belongs_to(:user)

	validates(:sent, presence: true, numericality: true, length: { maximum: 10 })

	validates(:received, presence: true, numericality: true, length: { maximum: 10 })

end
