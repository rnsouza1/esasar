class ChangeNameColumnJobJobHistory < ActiveRecord::Migration[5.1]
  def change
  	rename_column :job_histories, :job, :job_name
  	rename_column :jobs, :job, :job_name
  end
end
