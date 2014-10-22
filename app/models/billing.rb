require "active_record"

class Billing < ActiveRecord::Base

	belongs_to(:user)

	has_many(:payments, dependent: :destroy)
	has_many(:fees, dependent: :destroy)

	validates(:deposit, presence: true, format: { with: /\d{,15}(?:\.\d{0,6})?/ })

end
