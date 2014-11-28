require "active_record"

class AbonementUser < ActiveRecord::Base
	belongs_to(:user)
	belongs_to(:abonement)
end
