require 'csv' 
require 'rubygems'
require 'net/ssh'

##### to call this method send date by shell using this cmd: rake datastage_import:live
namespace :datastage_import do
  task :live => :environment do 

		@username = ENV['AHE_SERVER_USER']
		@password = ENV['AHE_SERVER_PWD']
		@hostname = "B03ACIAPP019.ahe.boulder.ibm.com"

		p "Address to login: " + @hostname + @username + @password[0..3]
		@ssh = Net::SSH.start(@hostname, @username, :password => @password)
		p "#{@ssh.host} Server logged!"


		while true
			p get_dsd_data = @ssh.exec!("/home/rnsouza/dsd.sh")
			
			begin
				directory = Rails.public_path
				file = File.open( File.join(directory, 'live_dsd_data.txt'), 'w') 
				#file.truncate(0)
				file.write(get_dsd_data)

			rescue IOError => e
				p "some error occur when try to open the file or dir is not writable."
			ensure
				file.close unless file.nil?
			end
			arr = Array.new
			p arr = File.readlines(File.join(directory, 'live_dsd_data.txt')).collect{|c| c.gsub!("\t\t", "").gsub!("\n", "").split("\t")[1..10]}
			sleep 5
			#file.close unless file.nil?
		end

	end


##### to call this method send date by shell using this cmd: rake datastage_import:jobs
  task :jobs => :environment do 
		directory = Rails.public_path
		@file_paths = ["datastage_jobs_list_esaopp.csv", "datastage_jobs_list_esadev.csv", "datastage_jobs_list_bi3.csv", "datastage_jobs_list_predictive_analytics.csv", "datastage_jobs_list_nrt.csv"]
		@ds_jobs_extracted = ""
		@ds_jobs_extracted += "<table border='1' dir='ltr' style='width: 1487px; table-layout: fixed; overflow-wrap: break-word; border-collapse: collapse; border-color: rgb(105, 105, 105);'>\n"
		@ds_jobs_extracted += "<tbody sandbox='allow-same-origin allow-scripts allow-popups'>\n"
		@ds_jobs_extracted += "<tr sandbox='allow-same-origin allow-scripts allow-popups'>"
		@ds_jobs_extracted += "<td style='overflow: hidden; width: 150px; border-color: rgb(105, 105, 105); text-align: center; background-color: rgb(211, 211, 211);'><strong sandbox='allow-same-origin allow-scripts allow-popups'>Project</strong></td>"
		@ds_jobs_extracted += "<td style='overflow: hidden; width: 410px; border-color: rgb(105, 105, 105); text-align: center; background-color: rgb(211, 211, 211);'><strong sandbox='allow-same-origin allow-scripts allow-popups'>Folder</strong></td>"
		@ds_jobs_extracted += "<td style='overflow: hidden; width: 450px; border-color: rgb(105, 105, 105); text-align: center; background-color: rgb(211, 211, 211);'><strong sandbox='allow-same-origin allow-scripts allow-popups'>Job</strong></td>"
		@ds_jobs_extracted += "<td style='overflow: hidden; width: 250px; border-color: rgb(105, 105, 105); text-align: center; background-color: rgb(211, 211, 211);'><strong sandbox='allow-same-origin allow-scripts allow-popups'>Dependency</strong></td>"
		@ds_jobs_extracted += "</tr>\n"
		@file_paths.each do |file_path|
			file = File.open(File.join(directory, file_path))
			@csv = CSV.parse(file, :headers => false)
			p "Loading #{file_path} data into Jobs Table (Datastage)..."
			@csv.each do |cs|
				print = true
				if cs.first.include? "/"
					col_splitted = cs.first.split("/")
					@project = col_splitted[0]
					@job_path = col_splitted[1..10].join("/") + "/"
					print = false
				end
				if print && cs.second != "Removed!"
					@ds_jobs_extracted += "\n<tr><td>" + @project + "</td><td>/" + @job_path + "</td><td>" + cs.first + "</td><td>" + cs.second.to_s + "</td></tr>" 
					p @ds_jobs_extracted
				end
		  end
		  file.close
	  end
	  @ds_jobs_extracted += "\n</tbody><table>"
	  file_output = File.open( File.join(directory, 'ds_jobs_extracted.html'), 'w') 
		#file_output.truncate(0)
		file_output.write(@ds_jobs_extracted)
		file_output.close
  end

##### to call this method send date by shell using this cmd: rake datastage_import:jobs
  task :import => :environment do 
		directory = Rails.public_path
		@file_paths = ["datastage_jobs_list_esaopp.csv", "datastage_jobs_list_esadev.csv", "datastage_jobs_list_bi3.csv", "datastage_jobs_list_predictive_analytics.csv", "datastage_jobs_list_nrt.csv"]
		@file_paths.each do |file_path|
			file = File.open(File.join(directory, file_path))
			@csv = CSV.parse(file, :headers => false)
			p "Loading #{file_path} data into Jobs Table (Datastage)..."
			@csv.each do |cs|
				print = true
				if cs.first.include? "/"
					col_splitted = cs.first.split("/")
					@project = col_splitted[0]
					@job_path = col_splitted[1..10].join("/") + "/"
					print = false
				end
				if print && cs.second != "Removed!"
					@ds_jobs_extracted += "\n<tr><td>" + @project + "</td><td>/" + @job_path + "</td><td>" + cs.first + "</td><td>" + cs.second.to_s + "</td></tr>" 
					p @ds_jobs_extracted
				end
		  end
		  file.close
	  end
	  @ds_jobs_extracted += "\n</tbody><table>"
	  file_output = File.open( File.join(directory, 'ds_jobs_extracted.html'), 'w') 
		file_output.truncate(0)
		file_output.write(@ds_jobs_extracted)
		file_output.close
  end

end