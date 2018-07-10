require 'csv'
class Job < ActiveRecord::Base

	has_many :job_histories, :dependent => :destroy
	has_many :job_tracks, :dependent => :destroy
	belongs_to :job_type

	def self.to_csv
	    attributes = %w{server_run workstation stream job_name schedule script user_id_run dependency}

	    CSV.generate(headers: true) do |csv|
	      csv << attributes

	      all.each do |j|
	        csv << attributes.map{ |attr| j.send(attr) }
	      end
	    end
	end

  def fulljobname
  	if self.job_type.job_type == "Tivoli"
	  	"#{self.workstation}##{self.stream}.#{self.job_name}"
	  else
	  	"#{self.workstation} - #{self.stream}/#{self.job_name}".upcase
	  end
	end

end

