class AddUrlAliasToWorkstation < ActiveRecord::Migration[5.1]
  def up
    add_column :workstations, :url_alias, :string
=begin
    Workstation.all.each do |w|
      w.url_alias = "b03aciapp#{w.name[/\d+/]}.ahe.boulder.ibm.com"
      w.save
    end
=end
  end

  def down
  	remove_column :workstations, :url_alias
  end


end
