class ChangeJobsColumnName < ActiveRecord::Migration[5.1]
  def change
  	rename_column :job_histories, :tivoli_job_id, :job_id
  end
end
