class CreateWorkstations < ActiveRecord::Migration[5.1]
  def change
    create_table :workstations do |t|
      t.string :name
      t.integer :port
      t.text :description
    end
  end
end
