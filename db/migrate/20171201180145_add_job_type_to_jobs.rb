class AddJobTypeToJobs < ActiveRecord::Migration[5.1]
  def change
  	drop_table :table_job_types

    create_table :job_types do |t|
      t.string :job_type
      t.text :description
    end

    add_reference :jobs, :job_type, foreign_key: true
  end
end
