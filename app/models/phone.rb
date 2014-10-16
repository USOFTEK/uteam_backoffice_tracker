require "active_record"

class Phone < ActiveRecord::Base

	belongs_to(:user)

	validate(:number, presence: true, length: { maximum: 50 })

	scope(:mobiles, -> { where(is_mobile: true) })
	scope(:regulars, -> { where(is_mobile: false) })
	scope(:primary, -> { where(is_main: true).first })
	scope(:secondaries, -> { where(is_main: false) })

end
