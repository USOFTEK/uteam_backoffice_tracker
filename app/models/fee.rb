require "active_record"

class Fee < ActiveRecord::Base
	before_save(:set_last_billing_deposit)

	belongs_to(:billing)

	delegate(:user, to: :billing, allow_nil: true)

	validates(:amount, presence: true, format: { with: /\d{,12}(?:\.\d{0,2})?/ })

	validates(:deposit, presence: true, format: { with: /\d{,15}(?:\.\d{0,6})?/ })

	validates(:ip, format: { with: /\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/ })

	private

	def set_last_billing_deposit
		self.deposit = billing.deposit
	end

end
