require 'csv'
class TivoliHistory < ActiveRecord::Base

	belongs_to :tivoli_job

  def self.to_csv
    attributes = %w{status server_run workstation stream job start_datetime end_datetime, elapsed_time}

    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.each do |j|
        csv << attributes.map{ |attr| j.send(attr) }
      end
    end
  end


end

