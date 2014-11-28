require "active_record"

class Tariff < ActiveRecord::Base

	has_many(:users)

	has_many(:tv_packages_tariffs)

	has_many(:tv_packages, through: :tv_packages_tariffs)

	validates(:name, presence: true, uniqueness: true)

	validates(:month_fee, presence: true, format: { with: /\d{,14}(?:\.\d{0,2})?/ }, numericality: { greater_than: 0 })

	validates(:day_fee, presence: true, format: { with: /\d{,14}(?:\.\d{0,2})?/ }, numericality: { greater_than: 0 })

end
