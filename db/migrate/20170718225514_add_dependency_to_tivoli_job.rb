class AddDependencyToTivoliJob < ActiveRecord::Migration[5.1]
  def change
    add_column :tivoli_jobs, :dependency, :string
  end
end
