require 'csv' 
require 'rubygems'
require 'net/ssh'

##### to call this method send date by shell using this cmd: rake datastage_import:live
namespace :datastage_import do
  task :live => :environment do 

		@username = ENV['AHE_SERVER_USER']
		@password = ENV['AHE_SERVER_PWD']
		@hostname = "B03ACIAPP019.ahe.boulder.ibm.com"
		@ssh = Net::SSH.start(@hostname, @username, :password => @password)
		p "#{@ssh.host} Server logged!"


		while true
			p get_dsd_data = @ssh.exec!("/home/rnsouza/dsd.sh")
			
			begin
				directory = Rails.public_path
				file = File.open( File.join(directory, 'live_dsd_data.txt'), 'w') 
				file.truncate(0)
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
end