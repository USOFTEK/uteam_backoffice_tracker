require "active_record"

class Phone < ActiveRecord::Base

	belongs_to(:user)

	#validates(:number, presence: true, length: { maximum: 50 })

	scope(:mobiles, -> { where(is_mobile: true) })
	scope(:regulars, -> { where(is_mobile: false) })
	scope(:secondaries, -> { where(is_main: false) })
	scope(:primaryies, -> { where(is_main: true) })

end
