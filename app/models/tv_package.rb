require "active_record"

class TvPackage < ActiveRecord::Base

	has_many(:tv_packages_tariffs)
	has_many(:tariffs, through: :tv_packages_tariffs)

	has_many(:tv_packages_abonements)
	has_many(:abonements, through: :tv_packages_abonements)

	validates(:name, presence: true, uniqueness: true, length: { minimum: 3 })

	validates(:source, presence: true, format: { with: /\Ahttps?:\/\/.+\z/i })

end
