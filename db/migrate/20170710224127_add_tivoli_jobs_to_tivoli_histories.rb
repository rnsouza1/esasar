class AddTivoliJobsToTivoliHistories < ActiveRecord::Migration[5.1]
  def change
    add_reference :tivoli_histories, :tivoli_job, index: true, foreign_key: true
  end

end
