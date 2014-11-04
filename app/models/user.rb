require "active_record"
require "paper_trail"
require "bcrypt"
require "active_record/diff"
require "date"

class User < ActiveRecord::Base
	include BCrypt
	include ActiveRecord::Diff

	has_paper_trail
	
	has_one(:billing, dependent: :destroy)

	has_many(:phones, dependent: :destroy)

	has_many(:network_activities, dependent: :destroy)
	
	delegate(:payments, to: :billing, allow_nil: true)

	delegate(:fees, to: :billing, allow_nil: true)

	belongs_to(:tariff)

	validates(:username, uniqueness: true, presence: true)

	validates(:password_hash, presence: true)

	validates(:netmask, format: { with: /\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/ })

	validates(:ip, format: { with: /\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/ })

	validates(:email, uniqueness: true, format: { with: /[\w\-\.]+@[\w\-]+(\.[a-z]+)*\.[a-z]+/i })

	validates(:registration, presence: true)

	scope(:disabled, -> { where(disable: true) })
	scope(:active, -> { where(disable: false) })

	def disabled?
		disable
	end

	def authenticate pass
		password == pass
	end

	def password
		@password ||= Password.new(password_hash)
	end

	def password= pwd
		self.password_hash = Password.create(pwd)
	end

	def credit round = 2
		@credit = billing.deposit - tariff.month_fee
		return @credit < 0 ? @credit.round(round) : 0
	end

	def self.public_fields
		[:initials, :address_street, :address_build, :address_flat, :username]
	end

	def created
		Time.at(created_at).to_i
	end

	def updated
		Time.at(updated_at).to_i
	end

	def registered
		DateTime.parse(registration.to_s).to_time.to_i
	end

end
