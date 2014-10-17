require "active_record"

class Tariff < ActiveRecord::Base

	has_many(:users)
	
	validates(:name, presence: true, uniqueness: true)

	validates(:month_fee, presence: true, format: { with: /\d{,14}(?:\.\d{0,2})?/ }, numericality: { greater_than: 0 })

	validates(:day_fee, presence: true, format: { with: /\d{,14}(?:\.\d{0,2})?/ }, numericality: { greater_than: 0 })

end