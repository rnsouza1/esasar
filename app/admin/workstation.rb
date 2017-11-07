ActiveAdmin.register Workstation do
  permit_params :name, :url, :port, :description
  
  index do
    selectable_column
    column :name
    column :url
    column :port
    column :description
    actions
  end

  filter :name
  filter :url
  filter :port
  filter :description

  form do |f|
    f.inputs "Workstation Details" do
      f.input :name
      f.input :url
      f.input :port
      f.input :description
    end
    f.actions
  end

end
