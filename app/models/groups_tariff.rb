require "active_record"

class GroupsTariff < ActiveRecord::Base
	belongs_to(:group)
	belongs_to(:tariff)
end
