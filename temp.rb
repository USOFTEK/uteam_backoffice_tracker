require "rubygems"
require "active_support/all"

Array.class_eval do
	def to_ranges
		ranges = Array.new
		unless empty?
			sort!
			# Initialize the left and right endpoints of the range
			left, right = shift, nil
			each { |e|
				left = right unless right.nil?
				right = e
				ranges << Range.new(left,right)
			}
		end
		ranges
	end
end

def make_weeks_ranges year, month
	date = Date.new(year, month)
	intervals = (date.beginning_of_month..date.end_of_month).select(&:sunday?).map(&:to_s).push([date.beginning_of_month.to_s, date.end_of_month.to_s]).flatten.uniq
	intervals.to_ranges
end

puts make_weeks_ranges(2014, 11)
