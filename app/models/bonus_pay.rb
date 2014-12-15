require "rubygems"
require "active_record"

class BonusPay < ActiveRecord::Base

	belongs_to(:user)

	scope(:unpaid,  -> { where(paid: false) })

	scope(:paid,  -> { where(paid: true) })

end
