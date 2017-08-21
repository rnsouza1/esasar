class AddElapsedTimeToTivoliHistory < ActiveRecord::Migration[5.1]
  def change
    add_column :tivoli_histories, :elapsed_time, :string
  end
end
