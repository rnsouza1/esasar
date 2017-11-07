require 'csv' 
require 'rubygems'
require 'net/ssh'

##### to call this method send date by shell using this cmd: rake tivoli_import:jobs_history[$(date +'%d/%m/%Y')]

##### to call this method send date by shell using this cmd: rake tivoli_import:jobs_history["02/08/2017, 21/08/2017"]
namespace :tivoli_import do
  task :jobs_history, [:dt_start, :dt_end] => :environment do |t, args|
	@dt_start = args[:dt_start]
	@dt_end = args[:dt_end]
	@username = ENV['AHE_SERVER_USER']
	@password = ENV['AHE_SERVER_PWD']
	@date_range = ( @dt_start.to_date..@dt_end.to_date ).map(&:to_date)
	#workstations = Rails.env.development? ? ENV['AHE_WORKSTATIONS_DEV'] : ENV['AHE_WORKSTATIONS_PROD']
	workstations = Workstation.select("id, url, port").all
	@count = 0
  p "Creating load script for date #{@dt_start} to #{@dt_end}"
	workstations.each do |w|
		@hostname = w.url
		@port = w.port
		p "#{@hostname} - #{@username}: xxxxx"
		@ssh = Net::SSH.start(@hostname, @username, {:password => @password, :port => @port})
		p "#{@hostname} Server logged!"
		
		query = []
		@date_range.each do |d| 
			year = d.strftime("%Y")
			tiv_file = []
			tiv_temp = []

			### uncomment this line below and comment the next line, if you want to perform the load for 1 specific job
			#tiv_temp = @ssh.exec!("/db2/db2load1/opstools/joblog/ahe_tiv #{d.strftime("%m.%d")} |grep EIW_OPPDTL_30_DM_30").split("\n")
			tiv_temp = @ssh.exec!("/db2/db2load1/opstools/joblog/ahe_tiv #{d.strftime("%m.%d")}").split("\n")
			@count 	+= tiv_temp.count

			# code below will produce array[STATUS, DT_START, DT_END, WORKSTATION#STREAM.JOB, LOG]
			tiv_file = tiv_temp.collect{|e| t = e.split(' '); [ t[0][0..2], t[1]+"/#{year} "+t[2], t[4]+"/#{year} "+t[5], t[7], t[8] ]; }

			tiv_file.each do |c|
				status					= c[0]
				workstation 		= c[3].split('#')[0]
				job_split				= c[3][13..99].split('.')
				stream 					= job_split[0]
				job 						= job_split[1]
				start_datetime 	= c[1]
				end_datetime		= c[2]
				log 						= c[4]
				
				tivoli_job_id = check_tivoli_job(workstation, stream, job, log)
				
				query << { "status" => status, "workstation" => workstation, "stream" => stream, "job" => job, "server_run" => @hostname , "start_datetime" => start_datetime.to_datetime, "end_datetime" => end_datetime.to_datetime, "log" => log, "tivoli_job_id" => tivoli_job_id } #, "user" => user, "script" => script }

				p status + ' ' + start_datetime.to_datetime.to_s + ' ' + end_datetime.to_datetime.to_s + ' ' + workstation + ' ' + stream + ' ' + job + ' ' + @hostname + ' ' + log  #+ ' ' +  user + ' ' +  script

		  end
		end
		p "saving data from server #{@hostname} on DB..."
		p query
  	TivoliHistory.create(query)
    p "History jobs updated!"
    p "Updating elapsed time..."
    if populate_elapsed_time
    	p "Elapsed time updated!"
    else 
    	p "Elapsed time got an error, please check!"
    end
	end
	
  end

##### to call this method using this cmd: rake tivoli_import:populate_tivoli_jobs

  task :populate_tivoli_jobs => :environment do
	@username = ENV['AHE_SERVER_USER']
	@password = ENV['AHE_SERVER_PWD']

    @tiv_jobs = TivoliHistory.distinct("workstation, stream, job, server_run").order("server_run").pluck("workstation, stream, job, server_run")
    worsktations = @tiv_jobs.collect{|t| t[3]}.uniq.sort
    worsktations.each do |w|
    	@w = w
    	@tiv_jobs_selected = @tiv_jobs.select{|e| e[3] == @w}
		p "#{@w} Server login!"
		@ssh = Net::SSH.start(@w, @username, :password => @password)
		p "logged Succ!"
	    @tiv_jobs_selected.each do |t|
	       	#job_name = "#{t[0]}##{t[1]}.#{t[2]}"
			jobs_hist = TivoliHistory.where(workstation: t[0], stream: t[1], job: t[2]).order(:start_datetime)
			
			job_hist = jobs_hist.last
			user_id_run = @ssh.exec!("head #{job_hist.log} |grep USER").split(' ')[3]
			script = @ssh.exec!("head #{job_hist.log} |grep JCLFILE").split(' ')[3..99].join(' ')

			schedule = set_schedule(jobs_hist)

			# Creating Record into Tivoli Jobs
			tiv_job = TivoliJob.new
			tiv_job.server_run = job_hist.server_run
			tiv_job.workstation = job_hist.workstation
			tiv_job.stream = job_hist.stream
			tiv_job.job = job_hist.job
			tiv_job.schedule = schedule
			tiv_job.script = script
			tiv_job.user_id_run = user_id_run
			if tiv_job.save
				# Updating Relation in tivoli history to tivoli jobs
				jobs_hist.update_all(tivoli_job_id: tiv_job.id)
			end
	    end
    end
  end

##### to call this method using this cmd: rake tivoli_import:dependency_load_from_file
##### file must be in public folder

  task :dependency_load_from_file => :environment do

 	### Parse CSV file from public dir
  directory = Rails.public_path
	file = File.open(File.join(directory, 'tivoli-jobs-2017-08-03.csv'))
	@csv = CSV.parse(file, :headers => true)

	p "Loading data into Tivoli Jobs Table..."
	@i = 0
	#query = []
	@csv.each do |c|
	  	row = TivoliJob.where("workstation = ? AND stream = ? AND job = ?", c[1], c[2], c[3]).first
	  	unless row.nil?
		  	p "row to be updated: "
		  	p row
	  		row.update(dependency: c[8])

		    p "job updated!"
		    @i += 1
		end
		p "#########################"
	end
	p "Rows updated: " + @i.to_s
  end


##### to call this method using this cmd: rake tivoli_import:populate_stream_related

  task :populate_stream_related => :environment do
  	tivoli_jobs = TivoliJob.all
  	tivoli_jobs.each do |tiv| 
  		new_stream = prepare_stream_related(tiv.stream)
  		tiv.update(stream_related: new_stream)
  	end

  end

##### to call this method using this cmd: rake tivoli_import:populate_elapsed_time
  task :populate_elapsed_time => :environment do
  	TivoliHistory.where(elapsed_time: nil).each do |t|
    	t.update( elapsed_time: Time.at(t.end_datetime - t.start_datetime).utc.strftime("%H:%M:%S") )
    end
	end


##### to call this method send date by shell using this cmd: rake tivoli_import:live["B03ACIAPP017.ahe.boulder.ibm.com"]
#  task :live, [:hostname] => :environment do |t, args|
  task :live, [:hostname] => :environment do
		@username = ENV['AHE_SERVER_USER']
		@password = ENV['AHE_SERVER_PWD']
		@ssh 			= []		
		workstations = Workstation.select("id, url, port").all
		#@hostname = args[:hostname]
		while true
			workstations.each do |w|
				@hostname = w.url			
				p "Address to login: " + @hostname + @username + @password[0..3]
				if @ssh[w.id].nil?
					@ssh[w.id] = Net::SSH.start(@hostname, @username, :password => @password)
					p "#{@ssh[w.id].host} Server logged!"
				end
				
				p tiv_data = @ssh[w.id].exec!("/db2/db2load1/opstools/joblog/ahe_tiv")
				
				# will collect new jobs from hist, will compare jobs collected from server with jobs from file saved at last run
				jobs_to_save = collect_jobs(tiv_data)

				# will save jobs and fill all fields and tables as necessary
				saved_status = save_finished_jobs(jobs_to_save, @ssh[w.id]) if jobs_to_save.size > 0
				
				# will save captured file into file at server public path
				store_job_history_collected_from_server(tiv_data) if saved_status
			end
			sleep 5
		end
	end



  private

  def collect_jobs(tiv_data)
 		# select only jobs as status is different of RUN
  	jobs_finished_from_server = tiv_data.split("\n").select{|e| e.split(" ")[0][0..2] != "RUN"}
  	jobs_from_file = File.readlines(File.join(Rails.public_path, 'live_tiv_data_'+@hostname+'.txt'))
  		.select{|e| e.split(" ")[0][0..2] != "RUN"}
  		.collect{|e| e.gsub("\n","")}
	  	
  	# get new jobs checking the difference between jobs hist arrays created above
  	return (jobs_finished_from_server - jobs_from_file)
  end

  def save_finished_jobs(jobs_to_save, ssh)
  	begin
		  @query = []
	  	jobs_to_save.each do |tiv|
	  		year = Date.today.strftime("%Y")

	  		t = tiv.split(' ')
				status					= t[0][0..2]
				workstation 		= t[7].split('#')[0]
				job_split				= t[7][13..99].split('.')
				stream 					= job_split[0]
				job 						= job_split[1]
				start_datetime 	= t[1]+"/#{year} "+t[2]
				end_datetime		= t[4]+"/#{year} "+t[5]
				log 						= t[8]
				elapsed_time 		= Time.at( Time.parse(end_datetime) - Time.parse(start_datetime) ).utc.strftime("%H:%M:%S")
				
				# create job at Job table only if it doesn't exist and return id to be created the relation into Job History table		
				tivoli_job_id = check_tivoli_job(workstation, stream, job, log, ssh)
				
				@query << { status: status, workstation: workstation, stream: stream, job: job, server_run: @hostname , start_datetime: start_datetime.to_datetime, end_datetime: end_datetime.to_datetime, log: log, tivoli_job_id: tivoli_job_id, elapsed_time: elapsed_time }
	  	end	
			p "saving data from server #{@hostname} on DB and query is:"
			p @query
	  	TivoliHistory.create(@query)
			p "jobs saved successfully!"
	    return true
	  rescue StandardError => e
	   	p e
	   	return false
	  end
  end

  def store_job_history_collected_from_server(data)
		begin
			directory = Rails.public_path
  		file_lock = File.open( File.join(directory, 'live_tiv_data_'+ @hostname +'.lock'), 'w')
  		file_lock.close
			file = File.open( File.join(directory, 'live_tiv_data_'+@hostname+'.txt'), 'w') 
			file.write(data)
			File.delete( File.join(directory, 'live_tiv_data_'+ @hostname +'.lock') )
		rescue IOError => e
			p "Got and error when writing data to the file."
			p e
		ensure
			file.close
		end
  end

  def populate_elapsed_time 
  	begin 
	  	TivoliHistory.where(elapsed_time: nil).each do |t|
	    	t.update( elapsed_time: Time.at(t.end_datetime - t.start_datetime).utc.strftime("%H:%M:%S") )
	    end
	  	return true
	  rescue StandardError => e
	  	p e 
	  	return false
	  end
	end

  def prepare_stream_related(stream)
  	stream_splitted = stream.split('_')
		i 							= stream_splitted.length - 1
		new_stream 			= stream_splitted[0..i-1].join('_') + stream_splitted[i] || ''
		return new_stream
  end

  def check_tivoli_job(workstation, stream, job, log, ssh)
  	tiv_original = TivoliJob.where(workstation: workstation, stream: stream, job: job)
  	if tiv_original.blank?
  		tiv = TivoliJob.where(workstation: workstation, stream_related: stream, job: job)
  	else 
  		tiv = tiv_original
  	end

		if tiv.blank?
			stream_related 	= prepare_stream_related(stream)
	  	user 						= ssh.exec!("head #{log} |grep USER").split(' ')[3]
			script 					= ssh.exec!("head #{log} |grep JCLFILE").split(' ')[3..99].join(' ')

			p tiv_new = TivoliJob.create(workstation: workstation, stream: stream, job: job, server_run: @hostname, user_id_run: user, script: script, stream_related: stream_related)
			
			return tiv_new.id
		else 
			return tiv.first.id
		end
  end

  def set_schedule(jobs_hist)
		@string_array = []
		jobs_hist.each do |j|
			@string_array.push(j.start_datetime.strftime("%a")[0..2])
		end
	 	return @string_array.uniq.join("','")
  end

end
