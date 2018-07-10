require 'csv'
class JobTrack < ActiveRecord::Base

	belongs_to :job

  def self.to_csv
    attributes = %w{title job_id description}

    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.each do |j|
        csv << attributes.map{ |attr| j.send(attr) }
      end
    end
  end


end

