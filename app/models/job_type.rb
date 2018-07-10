require 'csv'
class JobType < ActiveRecord::Base

	has_many :jobs

  def self.to_csv
    attributes = %w{job_type, description}

    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.each do |j|
        csv << attributes.map{ |attr| j.send(attr) }
      end
    end
  end


end

