require "active_record"

class TvPackagesTariff < ActiveRecord::Base

	belongs_to(:tv_package)

	belongs_to(:tariff)

	validate(:tv_package, presence: true)

	validate(:tariff, presence: true)

end
