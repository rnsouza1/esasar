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
		workstations = Workstation.all
		@job_type_id = JobType.where(job_type: "Tivoli").first.id
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
					begin
						status					= c[0]
						workstation 		= c[3].split('#')[0]
						job_split				= c[3][13..99].split('.')
						stream 					= job_split[0]
						job 						= job_split[1]
						start_datetime 	= c[1]
						end_datetime		= c[2]
						log 						= c[4]
						elapsed_time 		= Time.at( Time.parse(end_datetime) - Time.parse(start_datetime) ).utc.strftime("%H:%M:%S")
					rescue
						p c
					end
					
					tivoli_job_id = check_tivoli_job(workstation, stream, job, log, @ssh, @job_type_id)
					
					query << { "status" => status, "workstation" => workstation, "stream" => stream, "job_name" => job, "server_run" => @hostname , "start_datetime" => start_datetime.to_datetime, "end_datetime" => end_datetime.to_datetime, "log" => log, "job_id" => tivoli_job_id, "elapsed_time" => elapsed_time, "tivoli_job_id" => @job_type_id} 

					p status + ' ' + start_datetime.to_datetime.to_s + ' ' + end_datetime.to_datetime.to_s + ' ' +  elapsed_time + ' ' + workstation + ' ' + stream + ' ' + job + ' ' + @hostname + ' ' + log 

			  end
			end
			p "saving data from server #{@hostname} on DB..."
			p query
	  	JobHistory.create(query)
	    p "History jobs updated!"
		end	
  end


##### to call this method using this cmd: rake tivoli_import:populate_tivoli_jobs
### sunset - no longer used tivoli job as it changed to job and now it is populated by live run
=begin
  task :populate_tivoli_jobs => :environment do
		@username = ENV['AHE_SERVER_USER']
		@password = ENV['AHE_SERVER_PWD']

	  @tiv_jobs = JobHistory.distinct("workstation, stream, job_name, server_run").order("server_run").pluck("workstation, stream, job_name, server_run")
	  worsktations = @tiv_jobs.collect{|t| t[3]}.uniq.sort
	  worsktations.each do |w|
	  	@w = w
	  	@tiv_jobs_selected = @tiv_jobs.select{|e| e[3] == @w}
			p "#{@w} Server login!"
			@ssh = Net::SSH.start(@w, @username, :password => @password)
			p "logged Succ!"
	    @tiv_jobs_selected.each do |t|
				jobs_hist = JobHistory.where(workstation: t[0], stream: t[1], job_name: t[2]).order(:start_datetime)
				job_hist = jobs_hist.last
				user_id_run = @ssh.exec!("head #{job_hist.log} |grep USER").split(' ')[3]
				script = @ssh.exec!("head #{job_hist.log} |grep JCLFILE").split(' ')[3..99].join(' ')
				schedule = set_schedule(jobs_hist)

				# Creating Record into Tivoli Jobs
				tiv_job = Job.new
				tiv_job.server_run = job_hist.server_run
				tiv_job.workstation = job_hist.workstation
				tiv_job.stream = job_hist.stream
				tiv_job.job = job_hist.job_name
				tiv_job.schedule = schedule
				tiv_job.script = script
				tiv_job.user_id_run = user_id_run
				if tiv_job.save
					# Updating Relation in tivoli history to tivoli jobs
					jobs_hist.update_all(job_id: tiv_job.id)
				end
	    end
    end
  end
=end

##### to call this method using this cmd: rake tivoli_import:dependency_load_from_file
##### file must be in public folder

  task :dependency_load_from_file => :environment do

 	### Parse CSV file from public dir
	  directory = Rails.public_path
		file = File.open(File.join(directory, 'tivoli-jobs-2017-08-03.csv'))
		@csv = CSV.parse(file, :headers => true)

		p "Loading data into Tivoli Jobs Table..."
		@i = 0
		@csv.each do |c|
	  	row = Job.where("workstation = ? AND stream = ? AND job_name = ?", c[1], c[2], c[3]).first
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
  	tivoli_jobs = Job.all
  	tivoli_jobs.each do |tiv| 
  		new_stream = prepare_stream_related(tiv.stream)
  		tiv.update(stream_related: new_stream)
  	end
  end

##### to call this method using this cmd: rake tivoli_import:populate_elapsed_time
  task :populate_elapsed_time => :environment do
  	JobHistory.where(elapsed_time: nil).each do |t|
    	t.update( elapsed_time: Time.at(t.end_datetime - t.start_datetime).utc.strftime("%H:%M:%S") )
    end
	end


	task :collect_del_files => :environment do
		@username = ENV['AHE_SERVER_USER']
		@password = ENV['AHE_SERVER_PWD']
		@tables_csv = []
		workstations = Workstation.select("id, url, port").all

		workstations.each do |w|
			@w = w 
			@port = @w.port
			p "Address to login: " + @w.url + @username + @password[0..3]
			@ssh = Net::SSH.start(@w.url, @username, {:password => @password, :port => @port})
			p "#{@ssh.host} Server logged!"

			Job.where("job_name like '%LOAD%'").where(server_run: @w.url).each do |tj|
				tjh = tj.job_histories.where(status: "AOK").where("start_datetime > '#{(DateTime.now - 30.days).to_datetime}'").order("start_datetime DESC").first

				unless tjh.blank?
					unless tjh.stream == "EIW_ERDM"
						@ssh.exec!("grep 'of table' #{tjh.log} |grep -i load").split("\n").each do |table|
							begin 
								t = table.split(" ")
								@tables_csv << [ tjh.workstation+"#"+tjh.stream+"."+tjh.job_name, t[3], t[6] ]
								p tjh.workstation+"#"+tjh.stream+"."+tjh.job_name + ", " + t[3] + ", " + t[6] 
							rescue
								p "Error, please check error line:"
								p tj
								p tjh 
							end
						end
					end
				end
			end

		end
		directory = Rails.public_path
		file = File.open( File.join(directory, 'tiv_job_tables.csv'), 'w')
		file.write(@tables_csv)
		p @tables_csv
	end 

	task :intersect_del_files_with_jobs_pda => :environment do
		@csv_final = "Load Job,Table,Schedule,Del files,"+"\n"
		directory = Rails.public_path
		pda_jobs = File.read(File.join(directory, 'pda_job_tables.csv'))

		pda_json = JSON.parse(pda_jobs)
		pda_json.each do |ej|
			@ej = ej
			pda_dels = CSV.foreach( File.join(directory, 'PDA_del_files_mapped.csv')) do |r|
				if ej[1] == r[1] && ej[2] == r[0]
					begin
						@csv_final += ej[0] + "," + ej[1] + "," + ej[2] + ",'" + r[2] + "\n"
					rescue
						p "Error pls check"
					end
					@csv_final += "',\n"
					p ej[0] + "," + ej[1] + "," + ej[2] + "," + r[0] +","+ r[1] +","+ r[2] + "\n"
				end
			end
		end
	end

	task :intersect_del_files_with_jobs_pda_compacted => :environment do
		@csv_final = "Load Job,Table,Schedule,Del files"
		directory = Rails.public_path
		pda_jobs = File.read(File.join(directory, 'pda_job_tables.csv'))
		@job 			= ""
		@table 		= ""
		@schedule 	= ""

		pda_json = JSON.parse(pda_jobs)
		pda_json.each do |ej|
			@ej = ej
			pda_dels = CSV.foreach( File.join(directory, 'PDA_del_files_mapped.csv')) do |r|
				if ej[1] == r[1] && ej[2] == r[0]
					begin
						if ej[0] == @job && ej[1] == @table && ej[2] == @schedule
							@csv_final += "\n" + r[2] 
						else
							@csv_final += "',\n" + ej[0] + "," + ej[1] + "," + ej[2] + ",'" + r[2] 
						end
					rescue StandardError => e
						p "Error pls check"
					end
					p ej[0] + "," + ej[1] + "," + ej[2] + "," + r[0] +","+ r[1] +","+ r[2] + "\n"
					@job 			= ej[0]
					@table 		= ej[1]
					@schedule 	= ej[2]
				end
			end
		end

		file = File.open( File.join(directory, 'PDA_jobs_intersect_final.csv'), 'w')
		file.write(@csv_final)
	end

	task :intersect_del_files_with_jobs_esa => :environment do
		@csv_final = "Load Job,Table,Schedule,Del files,"+"\n"
		directory = Rails.public_path
		esa_jobs = File.read(File.join(directory, 'esa_job_tables.csv'))

		esa_json = JSON.parse(esa_jobs)
		esa_json.each do |ej|
			@ej = ej
			esa_dels = CSV.foreach( File.join(directory, 'ESADM_del_files_mapped.csv')) do |r|
				if ej[1] == r[1] && ej[2] == r[0]
					begin
						@csv_final += ej[0] + "," + ej[1] + "," + ej[2] + ",'" + r[2]+r[3] + ",\n"
						p ej[0] + "," + ej[1] + "," + ej[2] + "," + r[0] +","+ r[1] +","+ r[2]+r[3] + ",\n"

						r[4..20].each do |a|
							unless a.nil?
								a.split(",").each do |z|
									@csv_final += ej[0] + "," + ej[1] + "," + ej[2] + ",'" + z + ",\n"
									p ej[0] + "," + ej[1] + "," + ej[2] + ",'" + z + ",\n"
								end
							end
						end
					rescue StandardError => e
						puts e
					end
				end
			end
		end

		file = File.open( File.join(directory, 'ESA_jobs_intersect_final.csv'), 'w')
		file.write(@csv_final)

	end


##### to call this method send date by shell using this cmd: rake tivoli_import:live
  task :live => :environment do
		@username = ENV['AHE_SERVER_USER']
		@password = ENV['AHE_SERVER_PWD']
		@ssh 			= []		
		workstations = Workstation.select("id, url, port").all
		while true
			workstations.each do |w|
				@hostname = w.url			
				@port = w.port
				p "Address to login: " + @hostname + ":" + @port.to_s + " - " + @username + @password[0..3]
				if @ssh[w.id].nil?
					@ssh[w.id] = Net::SSH.start(@hostname, @username, {:password => @password, :port => @port})
					p "#{@ssh[w.id].host} Server logged!"
				end
				
				tiv_data = @ssh[w.id].exec!("/db2/db2load1/opstools/joblog/ahe_tiv")
				
				# will collect new jobs from hist, will compare jobs collected from server with jobs from file saved at last run
				jobs_to_save = collect_jobs(tiv_data)

				# will save jobs and fill all fields and tables as necessary
				saved_status = true
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
  	jobs_from_file = $redis.get('live_tiv_data_'+@hostname+'.'+@port.to_s)
  	if jobs_from_file.blank?
	  	return jobs_finished_from_server	
  	else
  		# get new jobs checking the difference between jobs hist arrays created above
  		jobs = jobs_from_file.split("\n").select{|e| e.split(" ")[0][0..2] != "RUN"} 
  		return (jobs_finished_from_server - jobs)
  	end
  end

  def save_finished_jobs(jobs_to_save, ssh)
  	begin
		  @query = []
		  @job_type_id = JobType.where(job_type: "Tivoli").first.id
	  	jobs_to_save.each do |tiv|
	  		year = Date.today.strftime("%Y")

	  		t = tiv.split(' ')
				status					= t[0][0..2]
				workstation 		= t[7].split('#')[0]
				job_split				= t[7][13..99].split('.')
				stream 					= job_split[0]
				job_name				= job_split[1]
				start_datetime 	= t[1]+"/#{year} "+t[2]
				end_datetime		= t[4]+"/#{year} "+t[5]
				log 						= t[8]
				elapsed_time 		= Time.at( Time.parse(end_datetime) - Time.parse(start_datetime) ).utc.strftime("%H:%M:%S")
				
				# create job at Job table only if it doesn't exist and return id to be created the relation into Job History table		
				tivoli_job_id = check_tivoli_job(workstation, stream, job_name, log, ssh, @job_type_id)
				
				@query << { status: status, workstation: workstation, stream: stream, job_name: job_name, server_run: @hostname+":"+@port.to_s, start_datetime: start_datetime.to_datetime, end_datetime: end_datetime.to_datetime, log: log, job_id: tivoli_job_id, elapsed_time: elapsed_time, job_type_id: @job_type_id }
	  	end	
			p "saving data from server #{@hostname}:#{@port.to_s} on DB and query is:"
			p @query
	  	JobHistory.create(@query)
			p "jobs saved successfully!"
	    return true
	  rescue StandardError => e
	   	p e
	   	return false
	  end
  end

  def store_job_history_collected_from_server(data)
		begin
			$redis.set("live_tiv_data_"+@hostname+"."+@port.to_s, data)
		rescue IOError => e
			p "Got and error when writing data to redis."
			p e
		ensure
			p $redis.get("live_tiv_data_"+@hostname+"."+@port.to_s)
		end
  end

  def populate_elapsed_time 
  	begin 
	  	JobHistory.where(elapsed_time: nil).each do |t|
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

  def check_tivoli_job(workstation, stream, job, log, ssh, job_type_id)
  	tiv_original = Job.where(workstation: workstation, stream: stream, job_name: job)
  	if tiv_original.blank?
  		tiv = Job.where(workstation: workstation, stream_related: stream, job_name: job)
  	else 
  		tiv = tiv_original
  	end

		if tiv.blank?
			stream_related 	= prepare_stream_related(stream)
	  	user 						= ssh.exec!("head #{log} |grep USER").split(' ')[3]
			script 					= ssh.exec!("head #{log} |grep JCLFILE").split(' ')[3..99].join(' ')
			#server_run			= Workstation.where(url: @hostname, port: @port.to_s).first
			p "Create new Tivoli Job in DB:"
			p tiv_new = Job.create(workstation: workstation, stream: stream, job_name: job, server_run: @hostname, user_id_run: user, script: script, stream_related: stream_related, job_type_id: job_type_id)
			
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
