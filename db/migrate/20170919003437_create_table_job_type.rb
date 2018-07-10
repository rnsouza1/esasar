class CreateTableJobType < ActiveRecord::Migration[5.1]
  def change
    create_table :table_job_types do |t|
      t.string :job_type
      t.text :description
    end
  end
end
