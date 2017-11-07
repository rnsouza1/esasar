require 'csv'
class Workstation < ActiveRecord::Base

	def self.to_csv
	    attributes = %w{name url port description}

	    CSV.generate(headers: true) do |csv|
	      csv << attributes

	      all.each do |j|
	        csv << attributes.map{ |attr| j.send(attr) }
	      end
	    end
	end

end

