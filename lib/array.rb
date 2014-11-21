require "rubygems"
require "active_support/all"

Array.class_eval do
	def to_weeks_ranges
		ranges = Array.new

		unless empty?
			left, right = shift, nil
			each { |e|
				left = right unless right.nil?
				right = e
				ranges << Range.new(left.to_time.to_s, right.to_time.to_s)
			}
		end

		ranges
	end

end
