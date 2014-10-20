require "active_record"
require "paper_trail"
require "bcrypt"

class User < ActiveRecord::Base
	include BCrypt

	# before_save(:encrypt_password)

	has_paper_trail
	
	has_one(:billing)

	has_many(:phones)

	has_many(:network_activities)
	
	delegate(:payments, to: :billing, allow_nil: true)
	
	delegate(:fees, to: :billing, allow_nil: true)

	belongs_to(:tariff)

	validates(:username, uniqueness: true, presence: true)

	validates(:password_hash, presence: true)

	validates(:netmask, format: { with: /\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/ })

	validates(:ip, format: { with: /\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/ })

	validates(:email, uniqueness: true, format: { with: /[\w\-\.]+@[\w\-]+(\.[a-z]+)*\.[a-z]+/i })

	validates(:registration, presence: true)

	def authenticate pass
		password == pass
	end

	def password
		@password ||= Password.new(password_hash)
	end

	def password= pwd
		self.password_hash = Password.create(pwd)
	end

	# private

	# def encrypt_password
	# 	self.password = Password.create(password)
	# end

end
