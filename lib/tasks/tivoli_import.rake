require 'csv' 
require 'rubygems'
require 'net/ssh'

##### to call this method send date by shell using this cmd: rake tivoli_import:jobs_history[$(date +'%d/%m/%Y')]

namespace :tivoli_import do
  task :jobs_history, [:dt_start, :dt_end] => :environment do |t, args|
	@dt_start = args[:dt_start] #args[:date_to_import].split(',')[0]
	@dt_end = args[:dt_end] #args[:date_to_import].split(',')[1]
	@username = ENV['AHE_SERVER_USER']
	@password = ENV['AHE_SERVER_PWD']
	@workstations = ["B03ACIAPP017.ahe.boulder.ibm.com","B03ACIAPP018.ahe.boulder.ibm.com","B03ACIAPP019.ahe.boulder.ibm.com"] 
	@date_range = ( @dt_start.to_date..@dt_end.to_date ).map(&:to_date) #.collect{|d| d.strftime("%m.%d")}
	@count = 0

  	p "Creating load script for date #{@dt_start} to #{@dt_end}"
	@workstations.each do |w|
		@hostname = w
		@ssh = Net::SSH.start(@hostname, @username, :password => @password)
		p "#{w} Server logged!"
		
		query = []
		@date_range.each do |d| 
			year = d.strftime("%Y")
			tiv_file = []
			tiv_temp = []

			### uncomment this line below and comment the next line, if you want to perform the load for 1 specific job
			#tiv_temp = @ssh.exec!("/db2/db2load1/opstools/joblog/ahe_tiv #{d.strftime("%m.%d")} |grep EIW_OPPDTL_30_DM_30").split("\n")
			tiv_temp = @ssh.exec!("/db2/db2load1/opstools/joblog/ahe_tiv #{d.strftime("%m.%d")}").split("\n")
			@count 	 += tiv_temp.count

			# code below will produce array[STATUS, DT_START, DT_END, WORKSTATION#STREAM.JOB, LOG]
			tiv_file = tiv_temp.collect{|e| t = e.split(' '); [ t[0][0..2], t[1]+"/#{year} "+t[2], t[4]+"/#{year} "+t[5], t[7], t[8] ]; }

			tiv_file.each do |c|
				status			= c[0]
				workstation 	= c[3].split('#')[0]
				job_split		= c[3][13..99].split('.')
				stream 			= job_split[0]
				job 			= job_split[1]
				start_datetime 	= c[1]
				end_datetime	= c[2]
				log 			= c[4]
				
				tivoli_job_id = check_tivoli_job(workstation, stream, job, @hostname, log, @ssh)
				
				query << { "status" => status, "workstation" => workstation, "stream" => stream, "job" => job, "server_run" => @hostname , "start_datetime" => start_datetime.to_datetime, "end_datetime" => end_datetime.to_datetime, "log" => log, "tivoli_job_id" => tivoli_job_id } #, "user" => user, "script" => script }

				p status + ' ' + start_datetime.to_datetime.to_s + ' ' + end_datetime.to_datetime.to_s + ' ' + workstation + ' ' + stream + ' ' + job + ' ' + @hostname + ' ' + log  #+ ' ' +  user + ' ' +  script

		  	end
		end
		p "saving data from server #{@hostname} on DB..."
		p query
	  	TivoliHistory.create(query)
	    p "jobs updated!"
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
  	TivoliHistory.all.each do |t|
    	t.update( elapsed_time: Time.at(t.end_datetime - t.start_datetime).utc.strftime("%H:%M:%S") )
    end
	end

  private

  def prepare_stream_related(stream)
  	stream_splitted = stream.split('_')
		i 							= stream_splitted.length - 1
		new_stream 			= stream_splitted[0..i-1].join('_') + stream_splitted[i] || ''
		return new_stream
  end

  def check_tivoli_job(workstation, stream, job, server_run, log, ssh)
  	tiv_original = TivoliJob.where(workstation: workstation, stream: stream, job: job)
  	if tiv_original.blank?
  		tiv = TivoliJob.where(workstation: workstation, stream_related: stream, job: job)
  	else 
  		tiv = tiv_original
  	end

	if tiv.blank?
		stream_related 	= prepare_stream_related(stream)
  		user 			= ssh.exec!("head #{log} |grep USER").split(' ')[3]
		script 			= ssh.exec!("head #{log} |grep JCLFILE").split(' ')[3..99].join(' ')

		p tiv_new = TivoliJob.create(workstation: workstation, stream: stream, job: job, server_run: server_run, user_id_run: user, script: script, stream_related: stream_related)
		
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
