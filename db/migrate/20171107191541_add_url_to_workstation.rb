class AddUrlToWorkstation < ActiveRecord::Migration[5.1]
  def change
    add_column :workstations, :url, :string
  end
end
