require "active_record"

class NetworkActivity < ActiveRecord::Base
	
	belongs_to(:user)

	validates(:sent, presence: true, numericality: true)

	validates(:received, presence: true, numericality: true)

	def at
		Time.at(per).to_i
	end

	def per_date
		Time.at(per).to_date.to_s
	end

end
