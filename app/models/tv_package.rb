require "active_record"

class TvPackage < ActiveRecord::Base



	validates(:name, presence: true, uniqueness: true, length: { minimum: 3 })

	validates(:source, presence: true, format: { with: /\Ahttps?:\/\/.+\z/i })

end
