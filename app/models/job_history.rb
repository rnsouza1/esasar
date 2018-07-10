require 'csv'
class JobHistory < ActiveRecord::Base

	belongs_to :job
  belongs_to :job_type

  def self.to_csv
    attributes = %w{status server_run workstation stream job_name start_datetime end_datetime, elapsed_time}

    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.each do |j|
        csv << attributes.map{ |attr| j.send(attr) }
      end
    end
  end


end

