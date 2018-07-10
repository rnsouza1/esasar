class AddJobTypeToJobHistory < ActiveRecord::Migration[5.1]
  def change
    add_reference :job_histories, :job_type, foreign_key: true
#    JobHistory.update_all(job_type_id: JobType.where(job_type: "Tivoli").first.id)
  end
end
