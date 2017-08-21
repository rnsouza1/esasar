require 'csv'
class TivoliJob < ActiveRecord::Base

	has_many :tivoli_histories, :dependent => :destroy

	def self.to_csv
	    attributes = %w{server_run workstation stream job schedule script user_id_run dependency}

	    CSV.generate(headers: true) do |csv|
	      csv << attributes

	      all.each do |j|
	        csv << attributes.map{ |attr| j.send(attr) }
	      end
	    end
	end

  	def fulljobname
	  "#{self.workstation}##{self.stream}.#{self.job}"
	end

end

