class CreateTivoliHistory < ActiveRecord::Migration[5.1]
  def change
    create_table :tivoli_histories do |t|
      t.string :workstation
      t.string :stream
      t.string :job
      t.string :server_run
      t.datetime :start_datetime
      t.datetime :end_datetime
      t.string :log
      t.string :status
      t.timestamps null: false
    end
  end
end
