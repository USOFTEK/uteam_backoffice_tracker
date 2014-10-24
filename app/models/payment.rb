require "active_record"

class Payment < ActiveRecord::Base
	before_save(:set_last_billing_deposit)

	belongs_to(:billing)

	delegate(:user, to: :billing, allow_nil: true)

	validates(:amount, presence: true, format: { with: /\d{,10}(?:\.\d{0,2})?/ })

	validates(:deposit, presence: true, format: { with: /\d{,15}(?:\.\d{0,6})?/ })

	validates(:ip, format: { with: /\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/ })

	def created
		Time.at(created_at).to_i rescue 0
	end

	private

	def set_last_billing_deposit
		unless deposit.nil?
			self.deposit = billing.deposit rescue 0
		end
	end

end
