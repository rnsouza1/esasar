class CreateTableJobTrack < ActiveRecord::Migration[5.1]
  def change
    create_table :job_tracks do |t|
      t.string :title
      t.references :job, foreign_key: true
      t.text :description
    end
  end
end
