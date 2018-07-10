class CreateTableTivoliJobs < ActiveRecord::Migration[5.1]
  def change
    create_table :tivoli_jobs do |t|
      t.string :workstation
      t.string :stream
      t.string :job
      t.string :server_run
      t.string :schedule
      t.string :script
      t.string :user_id_run
    end
  end
end
