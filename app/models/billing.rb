require "active_record"

class Billing < ActiveRecord::Base

	belongs_to(:user)

	has_many(:payments)
	has_many(:fees)

	validates(:deposit, presence: true, format: { with: /\d{,15}(?:\.\d{0,6})?/ })

end
