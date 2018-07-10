ActiveAdmin.register_page "Job Log" do

  #menu priority: 1, label: "Job Log"
  content title: "Job Log" do

  	@username = ENV['AHE_SERVER_USER']
		@password = ENV['AHE_SERVER_PWD']		
		@hostname = params[:server_run]			
		@port = params[:server_port]

		columns id: "Log view" do
	  	column do 
	  		panel "Job #{params[:job]}" do
					p "Server connected: " + @hostname + ":" + @port.to_s 
					unless @hostname.nil?
						@ssh = Net::SSH.start(@hostname, @username, {:password => @password, :port => @port})
					end
					div do 
						pre @ssh.exec!("cat #{params[:job_log]}")
					end
				end
	  	end
	  end
  end
end