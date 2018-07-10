class ChangeTivoliJobsToJobs < ActiveRecord::Migration[5.1]
  def change
	rename_table :tivoli_jobs, :jobs
	rename_table :tivoli_histories, :job_histories
	
  end
end
