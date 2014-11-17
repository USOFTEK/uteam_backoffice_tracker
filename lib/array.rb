require "rubygems"
require "active_support/all"

Array.class_eval do
	def to_weeks_ranges
		ranges = Array.new

		unless empty?
			left, right = shift, nil
			each { |e|
				left = right + 1.day unless right.nil?
				right = e
				ranges << Range.new(left.to_s, right.to_s)
			}
		end

		ranges
	end

end
