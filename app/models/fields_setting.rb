require "active_record"

class FieldsSetting < ActiveRecord::Base

	validates(:object, presence: true)

	def disallowed_fields
		selected.split(",") rescue []
	end

	def disallowed_fields= fields
		self.selected = fields.empty? ? nil : disallowed_fields.concat(fields).uniq.join(",")
	end

end
