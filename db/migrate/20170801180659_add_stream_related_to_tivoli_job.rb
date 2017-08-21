class AddStreamRelatedToTivoliJob < ActiveRecord::Migration[5.1]
  def change
    add_column :tivoli_jobs, :stream_related, :string
  end
end
