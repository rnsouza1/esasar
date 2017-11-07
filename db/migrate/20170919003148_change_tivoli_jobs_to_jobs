class ChangeSomeTablesNames < ActiveRecord::Migration[5.1]
  def change
	remove_index :TivoliJobs, :tivoli_job_id
    remove_foreign_key :TivoliHistories, :tivoli_jobs
	rename_table :TivoliJobs, :Jobs
	rename_table :TivoliHistories, :JobHistories
	add_foreign_key :JobHistories, :tivoli_jobs
    add_index :JobsHistories, :tivoli_job_id
  end
end
