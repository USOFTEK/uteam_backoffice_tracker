require "active_record"

class FieldsSetting < ActiveRecord::Base

	validates(:object, presence: true)

	def disallowed_fields
		disallowed.split(",") rescue []
	end

	def disallowed_fields= fields
		self.disallowed = fields.join(",")
	end

end
