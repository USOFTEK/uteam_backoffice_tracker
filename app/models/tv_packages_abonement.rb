require "active_record"

class TvPackagesAbonement < ActiveRecord::Base
	
	belongs_to(:tv_package)

	belongs_to(:abonement)

	validate(:tv_package, presence: true)

end
