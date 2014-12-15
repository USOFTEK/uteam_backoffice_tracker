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

	# has_many(:phones, dependent: :destroy)

	has_one(:mobile_phone, -> { where(is_mobile: true) }, class_name: "Phone", dependent: :destroy)

	accepts_nested_attributes_for(:mobile_phone, reject_if: ->(attributes) { attributes[:number].to_s.scan(/^(\+?([38]{2})?0\d{9}$)/i).empty? })

	has_one(:primary_phone, -> { where(is_main: true) }, class_name: "Phone", dependent: :destroy)

	has_many(:network_activities, dependent: :destroy)

	delegate(:payments, to: :billing, allow_nil: true)

	delegate(:fees, to: :billing, allow_nil: true)

	belongs_to(:tariff)

	belongs_to(:group)

	has_many(:abonement_users)

	has_many(:abonements, through: :abonement_users)

	has_many(:teams)

	has_many(:friends, through: :teams)

	has_many(:bonus_pays)

	validates(:initials, presence: true)

	validates(:username, uniqueness: true, presence: true)

	validates(:password_hash, presence: true)

	validates(:netmask, format: { with: /\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/ })

	validates(:ip, format: { with: /\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/ })

	validates(:email, uniqueness: true, format: { with: /[\w\-\.]+@[\w\-]+(\.[a-z]+)*\.[a-z]+/i })

	validates(:registration, presence: true)

	scope(:disabled, -> { where(disable: true) })

	scope(:active, -> { where(disable: false) })

	def has_tv
		!tariff.tv_package.nil? || abonements.with_tv.any?
	end

	def chat_notifications_allowed?
		chat_notification
	end

	def disabled?
		disable
	end

	def authenticate pass
		password == pass && group && group.authorizable?
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
		[:chat_notification, :mobile_phone_attributes]
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

	def self.available_fields disallowed = []
		Hash[public_fields.map { |f| [f, !disallowed.include?(f.to_s)] }] rescue {}
	end

	def bonuses
		friends.map(&:dillered).inject { |sum,x| sum + x }.round(2)
	end

	def dillered
		bonus_pays.unpaid.sum(:amount).round(2)
	end

end
